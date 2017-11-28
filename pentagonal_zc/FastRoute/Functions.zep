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

namespace FastRoute;

/**
 * Class Functions
 *
 * @package FastRoute
 */
class Functions
{
    protected static currentCalledCall = false;

    /**
     * @param callable routeDefinitionCallback
     * @param array options
     * @return Dispatcher
     */
    public static function simpleDispatcher(callable! routeDefinitionCallback, array options = []) -> <Dispatcher>
    {
        //self::createUserFunction();
        let options = options->merge([
            "routeParser"    : "FastRoute\\RouteParser\\Std",
            "dataGenerator"  : "FastRoute\\DataGenerator\\GroupCountBased",
            "dispatcher"     : "FastRoute\\Dispatcher\\GroupCountBased",
            "routeCollector" : "FastRoute\\RouteCollector"
        ]);

        var routeCollector,
            classNameCollector,
            classNameParser,
            classNameGenerator,
            classNameDispatcher;
        let classNameCollector = options["routeCollector"];
        let classNameParser = options["routeParser"];
        let classNameGenerator = options["dataGenerator"];
        let classNameDispatcher = options["dispatcher"];
        /** @var RouteCollector $routeCollector */
        let routeCollector = new {classNameCollector}(
            new {classNameParser},
            new {classNameGenerator}
        );
        {routeDefinitionCallback}(routeCollector);

        return new {classNameDispatcher}(routeCollector->getData());
    }

    /**
     * @param callable routeDefinitionCallback
     * @param array options
     * @return Dispatcher
     */
    public static function cachedDispatcher(callable! routeDefinitionCallback, array options = []) -> <Dispatcher>
    {
        //self::createUserFunction();
        let options = options->merge([
            "routeParser"    : "FastRoute\\RouteParser\\Std",
            "dataGenerator"  : "FastRoute\\DataGenerator\\GroupCountBased",
            "dispatcher"     : "FastRoute\\Dispatcher\\GroupCountBased",
            "routeCollector" : "FastRoute\\RouteCollector",
            "cacheDisabled"  : false
        ]);

        if  ! isset options["cacheFile"]  {
            throw new \LogicException("Must specify \"cacheFile\" option");
        }

        var dispatchData,
            routeCollector,
            classNameCollector,
            classNameParser,
            classNameGenerator,
            classNameDispatcher;
        if  ! options["cacheDisabled"] && file_exists(options["cacheFile"]) {
            let dispatchData = require options["cacheFile"];
            if ( ! is_array(dispatchData)) {
                throw new \RuntimeException("Invalid cache file \"" . options["cacheFile"] . "\"");
            }
            let classNameDispatcher = options["dispatcher"];
            return new {classNameDispatcher}(dispatchData);
        }

        let classNameCollector = options["routeCollector"];
        let classNameParser = options["routeParser"];
        let classNameGenerator = options["dataGenerator"];
        let classNameDispatcher = options["dispatcher"];
        let routeCollector = new {classNameCollector}(
            new {classNameParser},
            new {classNameGenerator}
        );
        {routeDefinitionCallback}(routeCollector);

        /** @var RouteCollector $routeCollector */
        let dispatchData = routeCollector->getData();
        if  ! options["cacheDisabled"] {
            file_put_contents(
                options["cacheFile"],
                "<?php return " . var_export(dispatchData, true) . ";"
            );
        }

        return new {classNameDispatcher}(dispatchData);
    }
}
