namespace FastRoute;

/**
 * Class RouteCollector
 * @package FastRoute
 */
class RouteCollector
{
    /**
     * @var RouteParser
     */
    protected routeParser;

    /**
     * @var DataGenerator
     */
    protected dataGenerator;

    /**
     * @var string
     */
    protected currentGroupPrefix;

    /**
     * Constructs a route collector.
     *
     * @param RouteParser   routeParser
     * @param DataGenerator dataGenerator
     */
    public function __construct(<RouteParser> routeParser, <DataGenerator> dataGenerator)
    {
        let this->routeParser = routeParser;
        let this->dataGenerator = dataGenerator;
        let this->currentGroupPrefix = "";
    }

    /**
     * Adds a route to the collection.
     *
     * The syntax used in the route string depends on the used route parser.
     *
     * @param string|string[] httpMethod
     * @param string route
     * @param mixed  handler
     */
    public function addRoute(httpMethod, string route, handler) -> void
    {
        if !is_array(httpMethod) {
            let httpMethod = [httpMethod];
        }

        var routeDatas = [], method, routeData;
        let route = this->currentGroupPrefix . route;
        let routeDatas = this->routeParser->parse(route);
        for method in httpMethod {
            for routeData in routeDatas {
                this->dataGenerator->addRoute(method, routeData, handler);
            }
        }
    }

    /**
     * Create a route group with a common prefix.
     *
     * All routes created in the passed callback will have the given group prefix prepended.
     *
     * @param string prefix
     * @param callable callback
     */
    public function addGroup(string! prefix, callable! callback)
    {
        var previousGroupPrefix;
        let previousGroupPrefix = this->currentGroupPrefix;
        let this->currentGroupPrefix = previousGroupPrefix . prefix;
        {callback}(this);
        let this->currentGroupPrefix = previousGroupPrefix;
    }
    
    /**
     * Adds a GET route to the collection
     * 
     * This is simply an alias of $this->addRoute("GET", $route, $handler)
     *
     * @param string route
     * @param mixed  handler
     */
    public function get(string! route, handler) -> void
    {
        this->addRoute("GET", route, handler);
    }
    
    /**
     * Adds a POST route to the collection
     * 
     * This is simply an alias of $this->addRoute("POST", $route, $handler)
     *
     * @param string route
     * @param mixed  handler
     */
    public function post(string! route, handler) -> void
    {
        this->addRoute("POST", route, handler);
    }
    
    /**
     * Adds a PUT route to the collection
     * 
     * This is simply an alias of $this->addRoute("PUT", $route, $handler)
     *
     * @param string route
     * @param mixed  handler
     */
    public function put(string! route, handler) -> void
    {
        this->addRoute("PUT", route, handler);
    }
    
    /**
     * Adds a DELETE route to the collection
     * 
     * This is simply an alias of $this->addRoute("DELETE", $route, $handler)
     *
     * @param string route
     * @param mixed  handler
     */
    public function delete(string! route, handler) -> void
    {
        this->addRoute("DELETE", route, handler);
    }
    
    /**
     * Adds a PATCH route to the collection
     * 
     * This is simply an alias of $this->addRoute("PATCH", $route, $handler)
     *
     * @param string route
     * @param mixed  handler
     */
    public function patch(string! route, handler) -> void
    {
        this->addRoute("PATCH", route, handler);
    }

    /**
     * Adds a HEAD route to the collection
     *
     * This is simply an alias of $this->addRoute("HEAD", $route, $handler)
     *
     * @param string route
     * @param mixed  handler
     */
    public function head(string! route, handler) -> void
    {
        this->addRoute("HEAD", route, handler);
    }

    /**
     * Returns the collected route data, as provided by the data generator.
     *
     * @return array
     */
    public function getData() -> array
    {
        return this->dataGenerator->getData();
    }
}
