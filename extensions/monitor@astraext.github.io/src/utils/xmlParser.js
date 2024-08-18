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
export default class XMLParser {
    constructor() {
        this.pos = 0;
        this.stack = [];
        this.currentObj = {};
        this.currentTagName = '';
        this.xml = '';
    }
    parse(xml) {
        this.xml = xml;
        this.resetParser();
        this.skipDeclarations();
        let rootObjName = '';
        const rootObj = {};
        while (this.pos < this.xml.length) {
            const nextLessThan = this.xml.indexOf('<', this.pos);
            if (nextLessThan === -1)
                break;
            if (nextLessThan !== this.pos) {
                const textContent = this.parseTextContent(this.pos);
                if (textContent && this.currentObj)
                    this.currentObj['#text'] = textContent;
            }
            this.pos = nextLessThan;
            this.skipToNextImportantChar();
            if (this.xml[this.pos] === '<') {
                if (this.xml[this.pos + 1] === '/') {
                    this.pos = this.xml.indexOf('>', this.pos) + 1;
                    const finishedObject = this.stack.pop();
                    if (this.stack.length === 0) {
                        if (rootObjName) {
                            rootObj[rootObjName] = finishedObject?.obj ?? {};
                            return rootObj;
                        }
                        return finishedObject?.obj;
                    }
                    this.currentObj = this.stack[this.stack.length - 1].obj;
                }
                else {
                    if (!this.parseTag())
                        break;
                    const attributes = this.parseAttributes();
                    const newObj = { ...attributes };
                    if (!this.currentObj) {
                        rootObjName = this.currentTagName;
                        this.currentObj = newObj;
                    }
                    else {
                        if (!this.currentObj[this.currentTagName])
                            this.currentObj[this.currentTagName] = newObj;
                        else if (Array.isArray(this.currentObj[this.currentTagName]))
                            this.currentObj[this.currentTagName].push(newObj);
                        else
                            this.currentObj[this.currentTagName] = [
                                this.currentObj[this.currentTagName],
                                newObj,
                            ];
                    }
                    this.stack.push({ tagName: this.currentTagName, obj: newObj });
                    this.currentObj = newObj;
                }
            }
            else {
                this.pos++;
            }
        }
        return undefined;
    }
    resetParser() {
        this.pos = 0;
        this.stack = [];
        this.currentObj = undefined;
        this.currentTagName = '';
    }
    skipDeclarations() {
        if (this.xml.startsWith('<?xml', this.pos))
            this.pos = this.xml.indexOf('?>', this.pos) + 2;
        while (this.xml[this.pos] === ' ' ||
            this.xml[this.pos] === '\n' ||
            this.xml[this.pos] === '\t' ||
            this.xml[this.pos] === '\r')
            this.pos++;
        if (this.xml.startsWith('<!DOCTYPE', this.pos))
            this.pos = this.xml.indexOf('>', this.pos) + 1;
        while (this.xml[this.pos] === ' ' ||
            this.xml[this.pos] === '\n' ||
            this.xml[this.pos] === '\t' ||
            this.xml[this.pos] === '\r')
            this.pos++;
    }
    skipToNextImportantChar() {
        const nextTagOpen = this.xml.indexOf('<', this.pos);
        const nextTagClose = this.xml.indexOf('>', this.pos);
        this.pos = nextTagOpen < nextTagClose && nextTagOpen !== -1 ? nextTagOpen : nextTagClose;
    }
    parseTag() {
        const firstSpace = this.xml.indexOf(' ', this.pos);
        const firstClosure = this.xml.indexOf('>', this.pos);
        const endOfTagName = firstSpace !== -1 && firstSpace < firstClosure ? firstSpace : firstClosure;
        if (endOfTagName === -1)
            return false;
        this.currentTagName = this.xml.substring(this.pos + 1, endOfTagName).trim();
        this.pos = endOfTagName;
        return true;
    }
    parseAttributes() {
        const attrs = {};
        while (this.xml[this.pos] === ' ')
            this.pos++;
        if (this.xml[this.pos] === '>') {
            this.pos++;
            return attrs;
        }
        while (this.pos < this.xml.length && this.xml[this.pos] !== '>') {
            let nextSpace = this.xml.indexOf(' ', this.pos);
            const nextEqual = this.xml.indexOf('=', this.pos);
            let endOfTag = this.xml.indexOf('>', this.pos);
            if (nextSpace === -1 || (nextEqual !== -1 && nextEqual < nextSpace))
                nextSpace = nextEqual;
            if (nextSpace === -1 || nextSpace > endOfTag)
                nextSpace = endOfTag;
            if (nextSpace === this.pos || nextSpace === -1)
                break;
            const attrName = '@' + this.xml.substring(this.pos, nextSpace);
            this.pos = nextSpace + 1;
            while (this.xml[this.pos] === ' ' && this.pos < endOfTag)
                this.pos++;
            if (this.xml[this.pos] === '=' ||
                this.xml[this.pos] === '"' ||
                this.xml[this.pos] === "'") {
                if (this.xml[this.pos] === '=') {
                    this.pos++;
                    while (this.xml[this.pos] === ' ')
                        this.pos++;
                }
                const quoteChar = this.xml[this.pos];
                if (quoteChar === '"' || quoteChar === "'") {
                    this.pos++;
                    const endQuote = this.xml.indexOf(quoteChar, this.pos);
                    const attrValue = this.xml.substring(this.pos, endQuote);
                    attrs[attrName] = attrValue;
                    this.pos = endQuote + 1;
                }
                else {
                    let spaceOrEndTag = this.xml.indexOf(' ', this.pos);
                    endOfTag = this.xml.indexOf('>', this.pos);
                    if (spaceOrEndTag === -1 || spaceOrEndTag > endOfTag)
                        spaceOrEndTag = endOfTag;
                    const attrValue = this.xml.substring(this.pos, spaceOrEndTag);
                    attrs[attrName] = isNaN(Number(attrValue)) ? attrValue : Number(attrValue);
                    this.pos = spaceOrEndTag;
                }
            }
            else {
                attrs[attrName] = true;
            }
            while (this.xml[this.pos] === ' ' && this.pos < endOfTag)
                this.pos++;
            if (this.xml[this.pos] === '>') {
                this.pos++;
                break;
            }
        }
        return attrs;
    }
    parseTextContent(startPos) {
        const endPos = this.xml.indexOf('<', startPos);
        const textContent = this.xml.substring(startPos, endPos).trim();
        this.pos = endPos;
        return textContent;
    }
}
