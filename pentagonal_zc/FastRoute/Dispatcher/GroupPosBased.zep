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

/**
 * Class GroupPosBased
 * @package FastRoute\Dispatcher
 */
class GroupPosBased extends RegexBasedAbstract
{
    public function __construct(array! data)
    {
        let this->staticRouteMap = reset(data);
        let this->variableRouteData = next(data);
    }

    protected function dispatchVariableRoute(array! routeData, string! uri) -> array
    {
        var data, matches;
        var arraySet, handler, varNames, vars, varName, i;
        for data in routeData {
            if !preg_match(data["regex"], uri, matches) {
                continue;
            }

            // find first non-empty match
            let i = 1;
            while ("" === matches[i]) {
                let i++;
            }

            //for let i = 1; "" === matches[i]; i++;

            let arraySet = data["routeMap"][i];
            let handler = reset(arraySet);
            let varNames = next(arraySet);

            let vars = [];
            for varName in varNames {
                let i++;
                let vars[varName] = matches[i];
            }

            return [self::FOUND, handler, vars];
        }

        return [self::NOT_FOUND];
    }
}
