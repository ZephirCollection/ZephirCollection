namespace FastRoute\DataGenerator;

/**
 * Class GroupCountBased
 * @package FastRoute\DataGenerator
 */
class GroupCountBased extends RegexBasedAbstract
{

    /**
     * Get Approximate Chunk Size
     *
     * @return int
     */
    protected function getApproxChunkSize() -> int
    {
        return 10;
    }

    /**
     * @param array regexToRoutesMap
     * @return array
     */
    protected function processChunk(array regexToRoutesMap) -> array
    {
        var routeMap = [], regex, route, regexes  = [], numGroups = 0;
        var numVariables;
        for regex, route in regexToRoutesMap {
            let numVariables = count(route->variables);
            let numGroups   = max(numGroups, numVariables);

            let regexes[] = regex . str_repeat("()", numGroups - numVariables);
            let routeMap[numGroups + 1] = [route->handler, route->variables];
            let numGroups++;
        }

        let regex = "~^(?|" . implode("|", regexes) . ")~";
        return ["regex" : regex, "routeMap" : routeMap];
    }
}

