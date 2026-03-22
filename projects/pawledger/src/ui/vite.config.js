import { defineConfig, transformWithEsbuild } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  optimizeDeps: {
    esbuildOptions: {
      loader: { ".js": "jsx" },
    },
  },
  plugins: [
    // Pre-transform .js files containing JSX before Vite's import analysis
    {
      name: "treat-js-as-jsx",
      enforce: "pre",
      async transform(code, id) {
        if (!id.includes("/node_modules/") && id.endsWith(".js") && code.includes("<")) {
          return transformWithEsbuild(code, id, { loader: "jsx" });
        }
      },
    },
    react(),
  ],
});
