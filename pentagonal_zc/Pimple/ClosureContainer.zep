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

namespace Pimple;

/**
 * Class ClosureContainer
 * @package ClosureContainer
 */
final class ClosureContainer
{
    /**
     * @var \Closure
     */
    private closure;
    /**
     * @var \stdClass
     */
    private std;

    /**
     * Closure constructor.
     */
    private function __construct()
    {
        let this->std = new \stdClass;
    }

    /**
     * @param \Closure closure
     * @param array use
     * @return ClosureContainer
     */
    public static function with(<\Closure> closure, array $use = []) -> <ClosureContainer>
    {
        var obj;
        let obj = new self;
        let obj->closure = closure;
        if $use->count() > 0 {
            var key, value, std;
            let std = obj->std;
            for key, value in $use {
                unset($use[key]);
                if ! is_string(key) {
                    throw new \InvalidArgumentException(
                        sprintf(
                            "Invalid arguments 2, key name must be as a string %s given",
                            typeof key
                        )
                    );
                }

                let std->{key} = value;
            }
        }

        return obj;
    }

    /**
     * @param string name
     * @param mixed value
     */
    public function set(string name, value) -> <ClosureContainer>
    {
        var std;
        let std = this->std;
        let std->{name} = value;
        return this;
    }

    /**
     * @param string name key name
     * @return mixed
     */
    public function get(name) -> var|null
    {
        if is_string(name) || is_numeric(name) || is_scalar(name) {
            if property_exists(this->std, name) {
                return this->std->{name};
            }

            return null;
        }

        throw new \InvalidArgumentException(
            sprintf(
                "Argument 1 must be as a string, %s given",
                typeof name
            )
        );
    }

    /**
     * if function is internal prevent binding
     */
    public function __invoke() -> var
    {
        var ref, args;
        let args = func_get_args();
        let ref = new \ReflectionFunction(this->closure);
        if ! ref->isInternal() {
            let this->closure = \Closure::bind(
                this->closure,
                this->std,
                "\stdClass"
            );
        } else {
            array_unshift(args, this);
        }

        return call_user_func_array(this->closure, args);
    }

    /**
     * @param string name
     */
    public function __get(name) -> var
    {
        return this->get(name);
    }
}
