namespace Pimple;

/**
 * Container main class.
 *
 * Class Container
 * @package Pimple
 */
class Container implements \ArrayAccess
{
    /**
     * @var array|mixed[]|object[]
     */
    private values = [];

    /**
     * @var \SplObjectStorage
     */
    private factories;

    /**
     * @var \SplObjectStorage
     */
    private $protected;

    /**
     * @var array|string[]
     */
    private frozen = [];

    /**
     * @var array|mixed[]|object[]
     */
    private raw = [];

    /**
     * @var array|bool[]
     */
    private keys = [];

    /**
     * Instantiates the container.
     *
     * Objects and parameters can be passed as argument to the constructor.
     *
     * @param array values The parameters or objects
     */
    public function __construct(array values = [])
    {
        let this->factories = new \SplObjectStorage;
        let this->$protected = new \SplObjectStorage;
        var key, value;
        for key, value in values {
            this->offsetSet(key, value);
        }
    }

    /**
     * Sets a parameter or an object.
     *
     * Objects must be defined as Closures.
     *
     * Allowing any PHP callable leads to difficult to debug problems
     * as function names (strings) are callable (creating a function with
     * the same name as an existing parameter would break your container).
     *
     * @param string id    The unique identifier for the parameter or object
     * @param mixed  value The value of the parameter or a closure to define an object
     * @throws Exception\FrozenServiceException Prevent override of a frozen service
     */
    public function offsetSet(string id, value)
    {
        if isset this->frozen[id] {
            throw new Exception\FrozenServiceException(id);
        }

        let this->values[id] = value;
        let this->keys[id] = true;
    }

    /**
     * Gets a parameter or an object.
     *
     * @param string id The unique identifier for the parameter or object
     * @return mixed The value of the parameter or an object
     * @throws Exception\UnknownIdentifierException If the identifier is not defined
     */
    public function offsetGet(string id) -> var
    {
        if ! isset this->keys[id] {
            throw new Exception\UnknownIdentifierException(id);
        }

        if
            isset this->raw[id]
            || ! is_object(this->values[id])
            || isset this->$protected[this->values[id]]
            || ! method_exists(this->values[id], "__invoke") {
            return this->values[id];
        }

        if isset this->factories[this->values[id]] {
               var method, values;
               let values = this->values;
               let method = values[id];
            return this->{method}(this);
        }
        var raw,
            val;
        let raw = this->values[id];
        let val = call_user_func(raw, this);
        let this->values[id] = val;
        let this->raw[id] = raw;
        let this->frozen[id] = true;

        return val;
    }

    /**
     * Checks if a parameter or an object is set.
     *
     * @param string id The unique identifier for the parameter or object
     * @return bool
     */
    public function offsetExists(string id) -> bool
    {
        return isset this->keys[id];
    }

    /**
     * Unsets a parameter or an object.
     *
     * @param string id The unique identifier for the parameter or object
     */
    public function offsetUnset(string id)
    {
        if isset this->keys[id] {
            if is_object(this->values[id]) {
                unset(this->factories[this->values[id]]);
                unset(this->$protected[this->values[id]]);
            }

            unset(this->values[id]);
            unset(this->frozen[id]);
            unset(this->raw[id]);
            unset(this->keys[id]);
        }
    }

    /**
     * Marks a callable as being a factory service.
     *
     * @param callable  callable A service definition to be used as a factory
     * @return callable The passed callable
     * @throws Exception\ExpectedInvokableException Service definition has to be a closure or an invokable object
     */
    public function factory(callable $callable) -> callable
    {
        if ! method_exists($callable, "__invoke") {
            throw new Exception\ExpectedInvokableException(
                "Service definition is not a Closure or invokable object."
            );
        }

        this->factories->attach($callable);

        return $callable;
    }

    /**
     * Protects a callable from being interpreted as a service.
     *
     * This is useful when you want to store a callable as a parameter.
     *
     * @param callable callable A callable to protect from being evaluated
     * @return callable The passed callable
     * @throws Exception\ExpectedInvokableException Service definition has to be a closure or an invokable object
     */
    public function protect(callable $callable) -> callable
    {
        if ! method_exists($callable, "__invoke") {
            throw new Exception\ExpectedInvokableException(
                "Callable is not a Closure or invokable object."
            );
        }

        this->$protected->attach($callable);

        return $callable;
    }

    /**
     * Gets a parameter or the closure defining an object.
     *
     * @param string id The unique identifier for the parameter or object
     * @return mixed The value of the parameter or the closure defining an object
     * @throws Exception\UnknownIdentifierException If the identifier is not defined
     */
    public function raw(string id) -> var
    {
        if ! isset this->keys[id] {
            throw new Exception\UnknownIdentifierException(id);
        }

        if isset this->raw[id] {
            return this->raw[id];
        }

        return this->values[id];
    }

    /**
     * Extends an object definition.
     *
     * Useful when you want to extend an existing object definition,
     * without necessarily loading that object.
     *
     * @param string   id       The unique identifier for the object
     * @param callable callable A service definition to extend the original
     * @return callable The wrapped callable
     * @throws Exception\UnknownIdentifierException        If the identifier is not defined
     * @throws Exception\FrozenServiceException            If the service is frozen
     * @throws Exception\InvalidServiceIdentifierException If the identifier belongs to a parameter
     * @throws Exception\ExpectedInvokableException        If the extension callable is not a closure or an invokable object
     */
    public function extend(string id, callable $callable) -> callable
    {
        if ! isset this->keys[id] {
            throw new Exception\UnknownIdentifierException(id);
        }

        if isset this->frozen[id] {
            throw new Exception\FrozenServiceException(id);
        }

        if ! is_object(this->values[id]) || !method_exists(this->values[id], "__invoke") {
            throw new Exception\InvalidServiceIdentifierException(id);
        }

        if isset this->$protected[this->values[id]] {
            trigger_error(
                sprintf(
                    "How Pimple behaves when extending protected closures will be fixed in Pimple 4. Are you sure \"%s\" should be protected?",
                    id
                ),
                E_USER_DEPRECATED
            );
        }

        if ! is_object($callable) || ! method_exists($callable, "__invoke") {
            throw new Exception\ExpectedInvokableException(
                "Extension service definition is not a Closure or invokable object."
            );
        }

        var factory, extended;
        let factory = this->values[id];

        /*
        // zephir does not support use statement scope
        let extended = function (c) use ($callable, factory) {
            return $callable(factory(c), c);
        };
        */

        let extended = \Pimple\ClosureContainer::with(function(<\Pimple\ClosureContainer> closure, c) {
                return call_user_func_array(closure->get("callable"), [
                    call_user_func(closure->get("factory"), c),
                    c
                ]);
            }, [ "callable": $callable, "factory": factory]);

        if isset this->factories[factory]  {
            this->factories->detach(factory);
            this->factories->attach(extended);
        }

        this->offsetSet(id, extended);
        return extended;
    }

    /**
     * Returns all defined value names.
     *
     * @return array An array of value names
     */
    public function keys() -> array
    {
        return array_keys(this->values);
    }

    /**
     * Registers a service provider.
     *
     * @param ServiceProviderInterface provider A ServiceProviderInterface instance
     * @param array                    values   An array of values that customizes the provider
     * @return static
     */
    public function register(<ServiceProviderInterface> provider, array values = []) -> <Container>
    {
        provider->register(this);
        var key, value;
        for key, value in values {
            this->offsetSet(key, value);
        }

        return this;
    }
}
