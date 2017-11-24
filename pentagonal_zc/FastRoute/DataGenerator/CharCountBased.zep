namespace FastRoute\DataGenerator;

/**
 * Class CharCountBased
 * @package FastRoute\DataGenerator
 */
class CharCountBased extends RegexBasedAbstract
{
    /**
     * Get Approximate Chunk Size
     *
     * @return int
     */
    protected function getApproxChunkSize() -> int
    {
        return 30;
    }

    /**
     * @param array regexToRoutesMap
     * @return array
     */
    protected function processChunk(array regexToRoutesMap) -> array
    {
        var routeMap = [],
            regexes  = [],
            suffixLen = 0,
            suffix = "",
            count = 0,
            regex,
            route;
        let count = count(regexToRoutesMap);
        for regex, route in regexToRoutesMap {
            let suffixLen++;
            let suffix .= "\t";
            let regexes[] = "(?:" . regex . "/(\t{" . suffixLen . "})\t{" . (count - suffixLen) . "})";
            let routeMap[suffix] = [route->handler, route->variables];
        }

        let regex = "~^(?|" . implode("|", regexes) . ")~";
        return ["regex" : regex, "suffix" : "/" . suffix, "routeMap" : routeMap];
    }
}
