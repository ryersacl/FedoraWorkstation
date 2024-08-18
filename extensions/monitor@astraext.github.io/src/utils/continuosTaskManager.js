/*!
 * Copyright (C) 2023 Lju
 *
 * This file is part of Astra Monitor extension for GNOME Shell.
 * [https://github.com/AstraExt/astra-monitor]
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import CancellableTaskManager from './cancellableTaskManager.js';
export default class ContinuosTaskManager {
    constructor() {
        this.output = '';
        this.listeners = new Map();
    }
    start(command, flushTrigger = '') {
        if (this.currentTask)
            this.currentTask.cancel();
        this.currentTask = new CancellableTaskManager();
        this.command = command;
        this.flushTrigger = flushTrigger;
        this.output = '';
        this.currentTask
            .run(this.task.bind(this))
            .catch(() => { })
            .finally(() => {
            this.stop();
        });
    }
    task() {
        return new Promise((resolve, reject) => {
            if (this.command === undefined) {
                reject('No command');
                return;
            }
            let argv;
            try {
                argv = GLib.shell_parse_argv(this.command);
                if (!argv[0])
                    throw new Error('Invalid command');
            }
            catch (e) {
                reject(`Failed to parse command: ${e.message}`);
                return;
            }
            const proc = new Gio.Subprocess({
                argv: argv[1],
                flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE,
            });
            try {
                proc.init(this.currentTask?.cancellable || null);
            }
            catch (e) {
                reject(`Failed to initialize subprocess: ${e.message}`);
                return;
            }
            this.currentTask?.setSubprocess(proc);
            const stdinStream = proc.get_stdin_pipe();
            const stdoutStream = new Gio.DataInputStream({
                baseStream: proc.get_stdout_pipe(),
                closeBaseStream: true,
            });
            this.readOutput(resolve, reject, stdoutStream, stdinStream);
        });
    }
    readOutput(resolve, reject, stdout, stdin) {
        stdout.read_line_async(GLib.PRIORITY_LOW, null, (stream, result) => {
            try {
                const [line] = stream.read_line_finish_utf8(result);
                if (line !== null) {
                    if (this.output.length)
                        this.output += '\n' + line;
                    else
                        this.output += line;
                    if (!this.flushTrigger || line.lastIndexOf(this.flushTrigger) !== -1) {
                        this.listeners.forEach((callback, _subject) => {
                            callback({ result: this.output, exit: false });
                        });
                        this.output = '';
                    }
                    this.readOutput(resolve, reject, stdout, stdin);
                }
                else {
                    this.listeners.forEach((callback, _subject) => {
                        callback({ exit: true });
                    });
                    resolve(true);
                }
            }
            catch (e) {
                this.listeners.forEach((callback, _subject) => {
                    callback({ exit: true });
                });
                resolve(false);
            }
        });
    }
    listen(subject, callback) {
        this.listeners.set(subject, callback);
    }
    unlisten(subject) {
        this.listeners.delete(subject);
    }
    stop() {
        if (this.currentTask)
            this.currentTask.cancel();
        this.currentTask = undefined;
    }
    get isRunning() {
        return this.currentTask?.isRunning || false;
    }
}
