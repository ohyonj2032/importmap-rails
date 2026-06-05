import DynamicImportmap from "../dynamic_importmap/index.js";

const ReactLazyBridge = (() => {
  let React = null;
  let SuspenseImpl = null;

  async function ensureReact() {
    if (React) return React;
    React = await import("react");
    SuspenseImpl = React.Suspense;
    return React;
  }

  function createLazyComponent(moduleName, cdnConfig, options = {}) {
    const { fallback = null, ssrFallback = null } = options;

    let LazyComponent = null;

    async function loadModule() {
      await DynamicImportmap.inject({ [moduleName]: cdnConfig });
      const module = await import(moduleName);
      return module.default || module;
    }

    function LazyWrapper(props) {
      if (!LazyComponent) {
        throw loadModule().then((comp) => {
          LazyComponent = comp;
        });
      }
      return React.createElement(LazyComponent, props);
    }

    LazyWrapper.displayName = `LazyBridge(${moduleName})`;
    LazyWrapper._preload = () => loadModule();

    return {
      Component: LazyWrapper,
      Suspense: SuspenseImpl,
      preload: () => loadModule(),
    };
  }

  function createLazyRoute(moduleName, cdnConfig, options = {}) {
    const { fallback } = options;

    return {
      render(props) {
        const { Component, Suspense } = createLazyComponent(moduleName, cdnConfig, options);
        return React.createElement(
          Suspense,
          { fallback: fallback || React.createElement("div", null, "Loading...") },
          React.createElement(Component, props)
        );
      },
    };
  }

  return { ensureReact, createLazyComponent, createLazyRoute };
})();

export default ReactLazyBridge;
