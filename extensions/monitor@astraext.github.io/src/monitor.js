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
import Utils from './utils/utils.js';
export default class Monitor {
    constructor(name) {
        this.timerID = null;
        this.listeners = new Map();
        this.usageHistory = new Map();
        this.enqueuedUpdates = [];
        this.nextCallTime = -1;
        this.usageHistoryLength = 200;
        this.name = name;
    }
    get updateFrequency() {
        Utils.log('UPDATE FREQUENCY MUST BE OVERWRITTEN');
        return -1;
    }
    get dueIn() {
        if (this.nextCallTime === -1)
            return -1;
        const dueInMicroseconds = this.nextCallTime - GLib.get_monotonic_time();
        return dueInMicroseconds / 1000;
    }
    get historyLength() {
        return this.usageHistoryLength;
    }
    start() {
        Utils.log(`Starting ${this.name} monitoring`);
        const updateFrequency = this.updateFrequency;
        if (this.timerID === null) {
            if (updateFrequency >= 0.1) {
                this.nextCallTime = GLib.get_monotonic_time() + updateFrequency * 1000000;
                this.timerID = GLib.timeout_add(GLib.PRIORITY_DEFAULT, updateFrequency * 1000, () => {
                    const res = this.update();
                    this.nextCallTime = GLib.get_monotonic_time() + updateFrequency * 1000000;
                    return res;
                });
            }
        }
    }
    stop() {
        Utils.log(`Stopping ${this.name} monitoring`);
        if (this.timerID) {
            GLib.source_remove(this.timerID);
            this.timerID = null;
            this.nextCallTime = -1;
        }
        this.resetData();
    }
    resetData() {
        this.usageHistory = new Map();
        this.enqueuedUpdates = [];
    }
    restart() {
        this.stop();
        this.start();
    }
    startListeningFor(_key) { }
    stopListeningFor(_key) { }
    update() {
        Utils.log('UPDATE MUST BE OVERWRITTEN');
        return true;
    }
    runTask({ key, task, run, callback }) {
        task.run(run)
            .then(callback)
            .catch(e => {
            if (e.isCancelled) {
                Utils.log(this.name + ' update canceled: ' + key);
            }
            else {
                Utils.error(`${this.name} - ${key}: ${e.message}`);
            }
        });
    }
    pushUsageHistory(key, value) {
        let values = this.usageHistory.get(key);
        if (values === undefined) {
            values = [];
            this.usageHistory.set(key, values);
        }
        if (this.enqueuedUpdates.includes(key) && values.length > 0) {
            values[0] = value;
            this.enqueuedUpdates = this.enqueuedUpdates.filter(k => k !== key);
        }
        else {
            values.unshift(value);
            if (values.length > this.usageHistoryLength)
                values.pop();
        }
    }
    setUsageValue(key, value) {
        this.usageHistory.set(key, [value]);
    }
    getUsageHistory(key) {
        const values = this.usageHistory.get(key);
        if (values === undefined)
            return [];
        return values;
    }
    getCurrentValue(key) {
        const values = this.usageHistory.get(key);
        if (values === undefined)
            return null;
        return values[0];
    }
    resetUsageHistory(key) {
        this.usageHistory.set(key, []);
    }
    requestUpdate(key) {
        if (!this.enqueuedUpdates.includes(key))
            this.enqueuedUpdates.push(key);
    }
    isListeningFor(key) {
        const listeners = this.listeners.get(key);
        if (!listeners)
            return false;
        return listeners.length > 0;
    }
    listen(subject, key, callback) {
        let listeners = this.listeners.get(key);
        if (listeners === undefined) {
            listeners = [];
            this.listeners.set(key, listeners);
        }
        for (const listener of listeners) {
            if (listener.subject === subject) {
                listener.callback = callback;
                return;
            }
        }
        listeners.push({ callback, subject });
        this.startListeningFor(key);
    }
    notify(key, value) {
        if (!Utils.ready)
            return;
        const listeners = this.listeners.get(key);
        if (listeners) {
            for (const listener of listeners)
                listener.callback(value);
        }
    }
    unlisten(subject, key) {
        if (key === undefined) {
            for (const listenerKey in this.listeners) {
                const listeners = this.listeners.get(listenerKey);
                if (listeners) {
                    const newListeners = listeners.filter(listener => listener.subject !== subject);
                    this.listeners.set(listenerKey, newListeners);
                    if (newListeners.length === 0)
                        this.stopListeningFor(listenerKey);
                }
            }
            return;
        }
        const listeners = this.listeners.get(key);
        if (listeners) {
            const newListeners = listeners.filter(listener => listener.subject !== subject);
            this.listeners.set(key, newListeners);
            if (newListeners.length === 0)
                this.stopListeningFor(key);
        }
    }
    destroy() {
        this.stop();
        this.listeners = new Map();
    }
}
