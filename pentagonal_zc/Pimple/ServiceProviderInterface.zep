namespace Pimple;

/**
 * Pimple service provider interface.
 *
 * Interface ServiceProviderInterface
 * @package Pimple
 */
interface ServiceProviderInterface
{
    /**
     * Registers services on the given container.
     *
     * This method should only be used to configure services and parameters.
     * It should not get services.
     *
     * @param Container pimple A container instance
     */
    public function register(<Container> pimple);
}
