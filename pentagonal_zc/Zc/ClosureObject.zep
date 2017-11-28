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

namespace Zc;

/**
 * Class ClosureObject
 * @package Zc
 */
final class ClosureObject implements \ArrayAccess
{
    /**
     * @var \Closure
     */
    private objectClosure;

    /**
     * @var \ArrayObject
     */
    private parameter;

    /**
     * @var object|null
     */
    private this = null;

    /**
     * @var string|mixed
     */
    private newScope = "static";

    /**
     * Closure constructor.
     */
    protected function __construct()
    {
        let this->parameter = new \ArrayObject();
    }

    /**
     * @param \Closure closure
     * @return ClosureObject
     */
    public static function make(<\Closure> closure) -> <\Zc\ClosureObject>
    {
        var obj, ref;
        let obj = new self;
        let ref = new \ReflectionFunction(closure);
        let obj->this = ref->getClosureThis();
        let obj->objectClosure = ref->getClosure();
        return obj->with(ref->getStaticVariables());
    }

    /**
     * @param \Closure closure
     * @param object newThis The object to which the given anonymous function should be bound, or NULL for the` closure to be unbound.
     * @param mixed newScope The class newScope to which associate the closure is to be associated, or 'static' to keep the current one.
     * @return ClosureObject
     */
    public static function bind(<\Closure> closure, object newThis, newScope = "static") -> <\Zc\ClosureObject>
    {
        return self::make(closure)
            ->bindTo(newThis, newScope);
    }

    public function bindTo(object bind, var newScope = "static") -> <\Zc\ClosureObject>
    {
        if !is_object(bind) && !is_null(bind) {
            throw new \InvalidArgumentException(
                sprintf(
                    "Param bind must be as object %s given",
                    typeof bind
                )
            );
        }

        let this->this = bind;
        let this->newScope = newScope;
        return this;
    }

    public function with(array! $use = []) -> <\Zc\ClosureObject>
    {
        if $use->count() > 0 {
            var key, value;
            for key, value in $use {
                this->set(key, value);
            }
        }

        return this;
    }

    /**
     * @param string name
     * @param mixed value
     */
    public function set(string name, value) -> <\Zc\ClosureObject>
    {
        this->parameter->offsetSet(name, value);
        return this;
    }

    /**
     * @param string name key name
     * @return mixed
     */
    public function get(name) -> var|null|callable
    {
        if is_string(name) || is_numeric(name) || is_scalar(name) {
            if this->parameter->offsetExists(name) {
                return this->parameter->offsetGet(name);
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
     * @return mixed|callable
     */
    public function __invoke() -> var|callable
    {
        var ref, args;
        let args = func_get_args();
        let ref = new \ReflectionFunction(this->objectClosure);
        array_unshift(args, this);
        if ! ref->isInternal() {
            let this->objectClosure = this->objectClosure->bindTo(
                this->this,
                this->newScope
            );
        }

        return call_user_func_array(this->objectClosure, args);
    }

    public function offsetExists(offset) -> bool
    {
        return this->parameter->offsetExists(offset);
    }

    public function offsetGet(offset) -> var|null|callable
    {
        return this->get(offset);
    }

    public function offsetSet(offset, value) -> void
    {
        this->set(offset, value);
    }

    public function offsetUnset(offset) -> void
    {
        if this->offsetExists(offset) {
            this->parameter->offsetUnset(offset);
        }
    }

    public function __unset(offset) -> void
    {
        this->offsetUnset(offset);
    }

    public function __isset(offset) -> bool
    {
        return this->offsetExists(offset);
    }

    public function getClosure() -> callable|<\Closure>
    {
        return this->objectClosure;
    }

    /**
     * @param string name
     * @return mixed
     */
    public function __get(offset) -> var|null|callable
    {
        return this->offsetGet(offset);
    }
}
