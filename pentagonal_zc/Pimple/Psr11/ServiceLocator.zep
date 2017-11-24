namespace Pimple\Psr11;

use Pimple\Container as PimpleContainer;
use Psr\Container\ContainerInterface;

/**
 * Pimple PSR-11 service locator.
 *
 * @author Pascal Luna <skalpa@zetareticuli.org>
 *
 * Class ServiceLocator
 * @package Pimple\Psr11
 */
class ServiceLocator implements ContainerInterface
{
    /**
     * @var \Pimple\Container
     */
    private container;

    /**
     * @var array
     */
    private aliases = [];

    /**
     * @param \Pimple\Container container The Container instance used to locate services
     * @param array           ids       Array of service ids that can be located. String keys can be used to define aliases
     */
    public function __construct(<PimpleContainer> container, array ids)
    {
        var id, key;
        let this->container = container;
        for key, id in ids {
            let this->aliases[is_int(key) ? id : key] = id;
        }
    }

    /**
     * Finds an entry of the container by its identifier and returns it.
     *
     * @param string id Identifier of the entry to look for.
     * @throws \Psr\Container\NotFoundExceptionInterface  No entry was found for **this** identifier.
     * @throws \Psr\Container\ContainerExceptionInterface Error while retrieving the entry.
     * @return mixed Entry.
     */
    public function get(string id) -> var
    {
        if ! isset this->aliases[id] {
            throw new \Pimple\Exception\UnknownIdentifierException(id);
        }

        return this->container[this->aliases[id]];
    }

    /**
     * Returns true if the container can return an entry for the given identifier.
     * Returns false otherwise.
     *
     * `has($id)` returning true does not mean that `get($id)` will not throw an exception.
     * It does however mean that `get($id)` will not throw a `NotFoundExceptionInterface`.
     *
     * @param string id Identifier of the entry to look for.
     * @return bool
     */
    public function has(string id) -> bool
    {
        return isset this->aliases[id] && isset this->container[this->aliases[id]];
    }
}
