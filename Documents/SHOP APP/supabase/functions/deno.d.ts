// Type definitions for Deno runtime in Supabase Edge Functions

declare namespace Deno {
  export interface Env {
    get(key: string): string | undefined;
    set(key: string, value: string): void;
    toObject(): Record<string, string>;
  }

  export const env: Env;

  export function serve(
    handler: (req: Request) => Promise<Response> | Response
  ): void;

  export function serve(
    options: { port?: number; hostname?: string; onListen?: (params: { port: number; hostname: string }) => void },
    handler: (req: Request) => Promise<Response> | Response
  ): void;
}
