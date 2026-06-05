declare module "react" {
  export const Suspense: any
  export const lazy: any
  export const useState: any
  const React: any
  export default React
}

declare module "react-dom/client" {
  export function createRoot(container: Element): {
    render(element: unknown): void
  }
}

declare module "react/jsx-runtime" {
  export const Fragment: unknown
  export function jsx(type: unknown, props: unknown, key?: unknown): unknown
  export function jsxs(type: unknown, props: unknown, key?: unknown): unknown
}