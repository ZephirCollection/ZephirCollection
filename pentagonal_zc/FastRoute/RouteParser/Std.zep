/**
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

namespace FastRoute\RouteParser;

use FastRoute\RouteParser;

/**
 * Parses route strings of the following form:
 *
 * "/user/{name}[/{id:[0-9]+}]"
 *
 * Class Std
 * @package FastRoute\RouteParser
 */
class Std implements RouteParser {
    const VARIABLE_REGEX = "
\\{
    \\s* ([a-zA-Z_][a-zA-Z0-9_-]*) \\s*
    (?:
        : \\s* ([^{}]*(?:\\{(?-1)\\}[^{}]*)*)
    )?
\\}";

    const DEFAULT_DISPATCH_REGEX = "[^/]+";
    /**
     * Parses a route string into multiple route data arrays.
     *
     * The expected output is defined using an example:
     *
     * For the route string "/fixedRoutePart/{varName}[/moreFixed/{varName2:\d+}]", if {varName} is interpreted as
     * a placeholder and [...] is interpreted as an optional route part, the expected result is:
     *
     * [
     *     // first route: without optional part
     *     [
     *         "/fixedRoutePart/",
     *         ["varName", "[^/]+"],
     *     ],
     *     // second route: with optional part
     *     [
     *         "/fixedRoutePart/",
     *         ["varName", "[^/]+"],
     *         "/moreFixed/",
     *         ["varName2", [0-9]+"],
     *     ],
     * ]
     *
     *
     * Here one route string was converted into two route data arrays.
     *
     * @param string $route Route string to parse
     * @return mixed[][] Array of route data arrays
     */
    public function parse(string! route) -> array
    {
        var routeWithoutClosingOptionals,
            numOptionals,
            segments,
            currentRoute,
            routeDatas;
        let currentRoute = "",
            routeDatas = [],
            routeWithoutClosingOptionals = rtrim(route, "]");
        let numOptionals = strlen(route) - strlen(routeWithoutClosingOptionals);
        // Split on [ while skipping placeholders
        let segments = preg_split("~" . self::VARIABLE_REGEX . "(*SKIP)(*F) | \\[~x", routeWithoutClosingOptionals);
        if numOptionals !== count(segments) - 1 {
            var regex;
            let regex = "~" . self::VARIABLE_REGEX . "(*SKIP)(*F) | \]~x";
            // If there are any ] in the middle of the route, throw a more specific error message
            if preg_match(regex, routeWithoutClosingOptionals) {
                throw new \FastRoute\BadRouteException("Optional segments can only occur at the end of a route");
            }

            throw new \FastRoute\BadRouteException("Number of opening '[' and closing ']' does not match");
        }


        var n, segment;
        for n, segment in segments {
            if segment === "" && n !== 0 {
                throw new \FastRoute\BadRouteException("Empty optional part");
            }

            let currentRoute .= segment;
            let routeDatas[] = this->parsePlaceholders(currentRoute);
        }

        return routeDatas;
    }

    /**
     * Parses a route string that does not contain optional segments.
     * @return array
     */
    private function parsePlaceholders(string! route) -> array
    {
        var matches, capture,set;
        let capture = PREG_OFFSET_CAPTURE | PREG_SET_ORDER;
        if ! preg_match_all(
            "~" . self::VARIABLE_REGEX . "~x",
            route,
            matches,
            capture
        ) {
            return [route];
        }
        var offset, routeData = [];
        let offset = 0;
        for set in matches {
            if set[0][1] > offset {
                let routeData[] = substr(route, offset, set[0][1] - offset);
            }
            let routeData[] = [
                set[1][0],
                isset set[2] ? trim(set[2][0]) : self::DEFAULT_DISPATCH_REGEX
            ];
            let offset = set[0][1] + strlen(set[0][0]);
        }

        if offset != strlen(route) {
            let routeData[] = substr(route, offset);
        }

        return routeData;
    }
}
