namespace FastRoute\DataGenerator;

use FastRoute\DataGenerator;
use FastRoute\BadRouteException;
use FastRoute\Route;

/**
 * Class RegexBasedAbstract
 * @package FastRoute\DataGenerator
 */
abstract class RegexBasedAbstract implements DataGenerator
{
    /**
     * @var array
     */
    protected staticRoutes = [];

    /**
     * @var array
     */
    protected methodToRegexToRoutesMap = [];

    /**
     * Get Approximate Chunk Size
     *
     * @return int
     */
    protected abstract function getApproxChunkSize() -> int;

    /**
     * @param array regexToRoutesMap
     * @return array
     */
    protected abstract function processChunk(array regexToRoutesMap) -> array;

    /**
     * Adds a route to the data generator. The route data uses the
     * same format that is returned by RouterParser::parser().
     *
     * The handler doesn"t necessarily need to be a callable, it
     * can be arbitrary data that will be returned when the route
     * matches.
     *
     * @param string    httpMethod
     * @param array     routeData
     * @param mixed     handler
     */
    public function addRoute(string! httpMethod, array routeData, handler) -> void
    {
        if (this->isStaticRoute(routeData)) {
            this->addStaticRoute(httpMethod, routeData, handler);
        } else {
            this->addVariableRoute(httpMethod, routeData, handler);
        }
    }

    /**
     * Get Route data
     *
     * @return array
     */
    public function getData() -> array
    {
        if (empty(this->methodToRegexToRoutesMap)) {
            return [this->staticRoutes, []];
        }

        return [this->staticRoutes, this->generateVariableRouteData()];
    }

    /**
     * Generate variable routes data
     *
     * @return array
     */
    private function generateVariableRouteData() -> array
    {
        var data;
        var chunkSize, chunks, regexToRoutesMap, method;
        let data = [];
        for method, regexToRoutesMap in this->methodToRegexToRoutesMap {
            let chunkSize = this->computeChunkSize(count(regexToRoutesMap));
            let chunks = array_chunk(regexToRoutesMap, chunkSize, true);
            let data[method] =  array_map([this, "processChunk"], chunks);
        }

        return data;
    }

    /**
     * Compute chunkz size
     *
     * @param int count
     * @return float
     */
    private function computeChunkSize(int! count) -> float
    {
        var numParts;
        let numParts = max(1, round(count / this->getApproxChunkSize()));
        return ceil(count / numParts);
    }

    /**
     * Check if static route
     *
     * @param array routeData
     * @return bool
     */
    private function isStaticRoute(array routeData) -> bool
    {
        return count(routeData) === 1 && is_string(routeData[0]);
    }

   /**
    * add static route
    *
    * @param string httpMethod
    * @param array routeData
    * @param mixed handler
    */
    private function addStaticRoute(string! httpMethod, array routeData, handler) -> void
    {
        var routeStr;
        let routeStr = routeData[0];
        if isset this->staticRoutes[httpMethod][routeStr] {
            throw new BadRouteException(sprintf(
                "Cannot register two routes matching \"%s\" for method \"%s\"",
                routeStr,
                httpMethod
            ));
        }

        if isset this->methodToRegexToRoutesMap[httpMethod] {
            var route;
            for route in this->methodToRegexToRoutesMap[httpMethod] {
                if route->matches(routeStr) {
                    throw new BadRouteException(sprintf(
                        "Static route \"%s\" is shadowed by previously defined variable route \"%s\" for method \"%s\"",
                        routeStr,
                        route->regex,
                        httpMethod
                    ));
                }
            }
        }

        let this->staticRoutes[httpMethod][routeStr] = handler;
    }

   /**
    * add static route
    *
    * @param string httpMethod
    * @param array routeData
    * @param mixed handler
    */
    private function addVariableRoute(string! httpMethod, array routeData, handler) -> void
    {
        var variables, regex, regexRoutes = [];
        let regexRoutes = this->buildRegexForRoute(routeData);
        let regex     = reset(regexRoutes);
        let variables = next(regexRoutes);

        if isset this->methodToRegexToRoutesMap[httpMethod][regex] {
            throw new BadRouteException(sprintf(
                "Cannot register two routes matching \"%s\" for method \"%s\"",
                regex,
                httpMethod
            ));
        }

        let this->methodToRegexToRoutesMap[httpMethod][regex] = new Route(
            httpMethod,
            handler,
            regex,
            variables
        );
    }

    /**
     * Build route regex
     *
     * @return array
     */
    private function buildRegexForRoute(array routeData) -> array
    {
        var regex = "", variables = [], part;
        var varName, regexPart;

        for part in routeData {
            if is_string(part) {
                let regex .= preg_quote(part, "~");
                continue;
            }

            let varName = reset(part);
            let regexPart = next(part);

            if isset variables[varName] {
                throw new BadRouteException(sprintf(
                    "Cannot use the same placeholder \"%s\" twice",
                    varName
                ));
            }

            if this->regexHasCapturingGroups(regexPart) {
                throw new BadRouteException(sprintf(
                    "Regex \"%s\" for parameter \"%s\" contains a capturing group",
                    regexPart,
                    varName
                ));
            }

            let variables[varName] = varName;
            let regex .= "(" . regexPart . ")";
        }

        return [regex, variables];
    }

    /**
     * Check if regex has cpturing group
     *
     * @param string regex
     * @return bool
     */
    private function regexHasCapturingGroups(string! regex) -> bool
    {
        if false === strpos(regex, "(") {
            // Needs to have at least a ( to contain a capturing group
            return false;
        }

        // Semi-accurate detection for capturing groups
        return (bool) preg_match(
            "~
                (?:
                    \(\?\(
                  | \[ [^\]\\\\]* (?: \\\\ . [^\]\\\\]* )* \]
                  | \\\\ .
                ) (*SKIP)(*FAIL) |
                \(
                (?!
                    \? (?! <(?![!=]) | P< | \" )
                  | \*
                )
            ~x",
            regex
        );
    }
}
