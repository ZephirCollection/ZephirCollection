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

namespace FastRoute\Dispatcher;

use FastRoute\Dispatcher;

/**
 * Class RegexBasedAbstract
 * @package FastRoute\Dispatcher
 */
abstract class RegexBasedAbstract implements Dispatcher
{
    /**
     * @var array
     */
    protected staticRouteMap;
    /**
     * @var array
     */
    protected variableRouteData;

    protected abstract function dispatchVariableRoute(array! routeData, string! uri) -> array;

    /**
     * Dispatches against the provided HTTP method verb and URI.
     *
     * Returns array with one of the following formats:
     *
     *     [self::NOT_FOUND]
     *     [self::METHOD_NOT_ALLOWED, ["GET", "OTHER_ALLOWED_METHODS"]]
     *     [self::FOUND, $handler, ["varName" => "value", ...]]
     *
     *
     * @param string httpMethod
     * @param string uri
     * @return array
     */
    public function dispatch(string! httpMethod, string! uri) -> array
    {
        var handler;
        if isset this->staticRouteMap[httpMethod][uri] {
            let handler = this->staticRouteMap[httpMethod][uri];
            return [self::FOUND, handler, []];
        }

        var varRouteData, result;
        let varRouteData = this->variableRouteData;
        if  isset varRouteData[httpMethod] {
            let result = this->dispatchVariableRoute(varRouteData[httpMethod], uri);
            if result[0] === self::FOUND {
                return result;
            }
        }

        // For HEAD requests, attempt fallback to GET
        if httpMethod === "HEAD" {
            if isset this->staticRouteMap["GET"][uri] {
                let handler = this->staticRouteMap["GET"][uri];
                return [self::FOUND, $handler, []];
            }

            if isset varRouteData["GET"] {
                let result = this->dispatchVariableRoute(varRouteData["GET"], uri);
                if result[0] === self::FOUND {
                    return result;
                }
            }
        }

        // If nothing else matches, try fallback routes
        if isset this->staticRouteMap["*"][uri] {
            let handler = this->staticRouteMap["*"][uri];
            return [self::FOUND, handler, []];
        }

        if isset varRouteData["*"] {
            let result = this->dispatchVariableRoute(varRouteData["*"], uri);
            if result[0] === self::FOUND {
                return result;
            }
        }

        var allowedMethods = [];
        var method, uriMap, routeData;
        // Find allowed methods for this URI by matching against all other HTTP methods as well
        let allowedMethods = [];
        for method, uriMap in this->staticRouteMap {
            if method !== httpMethod && isset uriMap[uri] {
                let allowedMethods[] = method;
            }
        }

        for method, routeData in varRouteData {
            if method === httpMethod {
                continue;
            }

            let result = this->dispatchVariableRoute(routeData, uri);
            if result[0] === self::FOUND {
                let allowedMethods[] = method;
            }
        }

        // If there are no allowed methods the route simply does not exist
        if ! empty allowedMethods {
            return [self::METHOD_NOT_ALLOWED, allowedMethods];
        } else {
            return [self::NOT_FOUND];
        }
    }
}
