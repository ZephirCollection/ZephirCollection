namespace FastRoute\DataGenerator;

/**
 * Class MarkBased
 * @package FastRoute\DataGenerator
 */
class MarkBased extends RegexBasedAbstract
{
    /**
     * Get Approximate Chunk Size
     *
     * @return int
     */
    protected function getApproxChunkSize()
    {
        return 30;
    }

    /**
     * @param array regexToRoutesMap
     * @return array
     */
    protected function processChunk(array regexToRoutesMap) -> array
    {
        var routeMap = [], regex, route, regexes  = [], markName;
        let markName = "a";
        for regex, route in regexToRoutesMap {
            let regexes[] = regex . "(*MARK:" . markName . ")";
            let routeMap[markName] = [route->handler, route->variables];

            let markName++;
        }

        let regex = "~^(?|" . implode("|", regexes) . ")~";
        return ["regex" : regex, "routeMap" : routeMap];
    }
}
