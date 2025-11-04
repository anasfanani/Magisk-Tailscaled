declare module 'kernelsu' {
  export interface ExecResult {
    errno: number;
    stdout: string;
    stderr: string;
  }

  export interface ExecOptions {
    cwd?: string;
    env?: Record<string, string>;
  }

  export function exec(
    command: string,
    options?: ExecOptions
  ): Promise<ExecResult>;
  export function toast(message: string): void;
  export function fullScreen(isFullScreen: boolean): void;
  export function spawn(
    command: string,
    args?: string[],
    options?: ExecOptions
  ): any;
}
