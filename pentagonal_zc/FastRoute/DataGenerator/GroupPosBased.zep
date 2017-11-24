namespace FastRoute\DataGenerator;

/**
 * Class GroupPosBased
 * @package FastRoute\DataGenerator
 */
class GroupPosBased extends RegexBasedAbstract
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
        var routeMap = [], regex, route, regexes  = [], offset = 1;

        for regex, route in regexToRoutesMap {
            let regexes[] = regex;
            let routeMap[offset] = [route->handler, route->variables];

            let offset += count(route->variables);
        }

        let regex = "~^(?:" . implode("|", regexes) . ")~";
        return ["regex" : regex, "routeMap" : routeMap];
    }
}
