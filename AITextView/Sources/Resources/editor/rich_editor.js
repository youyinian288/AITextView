/**
 * Copyright (C) 2015 Wasabeef
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 "use strict";

// 定义RE对象，用于封装富编辑器的所有功能
const RE = {};

// 获取编辑器元素
RE.editor = document.getElementById('editor');

// 监听选择变化事件，不是普遍支持，但在iOS 7和8中似乎有效
// 监听选择变化事件，不是普遍支持，但在iOS 7和8中似乎有效
document.addEventListener("selectionchange", function() {
    RE.backuprange();
});

// 检查是否存在范围选择（而不是光标选择）
RE.rangeSelectionExists = function() {
    //!! 将null强制转换为布尔值
    var sel = document.getSelection();
    if (sel && sel.type == "Range") {
        return true;
    }
    return false;
};

// 检查是否存在范围或光标选择
RE.rangeOrCaretSelectionExists = function() {
    //!! 将null强制转换为布尔值
    var sel = document.getSelection();
    if (sel && (sel.type == "Range" || sel.type == "Caret")) {
        return true;
    }
    return false;
};

// 监听编辑器输入事件
RE.editor.addEventListener("input", function() {
    RE.updatePlaceholder();
    RE.backuprange();
    RE.callback("input");
});

// 监听编辑器获得焦点事件
RE.editor.addEventListener("focus", function() {
    RE.backuprange();
    RE.callback("focus");
});

// 监听编辑器失去焦点事件
RE.editor.addEventListener("blur", function() {
    RE.callback("blur");
});

// 自定义操作
RE.customAction = function(action) {
    RE.callback("action/" + action);
};

// 更新高度
RE.updateHeight = function() {
    RE.callback("updateHeight");
}

// 回调队列
RE.callbackQueue = [];
// 运行回调队列
RE.runCallbackQueue = function() {
    if (RE.callbackQueue.length === 0) {
        return;
    }

    setTimeout(function() {
        window.location.href = "re-callback://";
        //window.webkit.messageHandlers.iOS_Native_FlushMessageQueue.postMessage("re-callback://")
    }, 0);
};

// 获取命令队列
RE.getCommandQueue = function() {
    var commands = JSON.stringify(RE.callbackQueue);
    RE.callbackQueue = [];
    return commands;
};

// 回调函数
RE.callback = function(method) {
    RE.callbackQueue.push(method);
    RE.runCallbackQueue();
};

// 设置HTML内容
RE.setHtml = function(contents) {
    var tempWrapper = document.createElement('div');
    tempWrapper.innerHTML = contents;
    var images = tempWrapper.querySelectorAll("img");

    for (var i = 0; i < images.length; i++) {
        images[i].onload = RE.updateHeight;
    }

    RE.editor.innerHTML = tempWrapper.innerHTML;
    RE.updatePlaceholder();
};

// 获取HTML内容
RE.getHtml = function() {
    return RE.editor.innerHTML;
};

// 获取文本内容
RE.getText = function() {
    return RE.editor.innerText;
};

// 设置基础文本颜色
RE.setBaseTextColor = function(color) {
    RE.editor.style.color  = color;
};

// 设置占位符文本
RE.setPlaceholderText = function(text) {
    RE.editor.setAttribute("placeholder", text);
};

// 更新占位符
RE.updatePlaceholder = function() {
    if (RE.editor.innerHTML.indexOf('img') !== -1 || RE.editor.innerHTML.length > 0) {
        RE.editor.classList.remove("placeholder");
    } else {
        RE.editor.classList.add("placeholder");
    }
};

// 移除格式
RE.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
};

// 设置字体大小
RE.setFontSize = function(size) {
    RE.editor.style.fontSize = size;
};

// 设置背景颜色
RE.setBackgroundColor = function(color) {
    RE.editor.style.backgroundColor = color;
};

// 设置高度
RE.setHeight = function(size) {
    RE.editor.style.height = size;
};

// 撤销操作
RE.undo = function() {
    document.execCommand('undo', false, null);
};

// 重做操作
RE.redo = function() {
    document.execCommand('redo', false, null);
};

// 设置粗体
RE.setBold = function() {
    document.execCommand('bold', false, null);
};

// 设置斜体
RE.setItalic = function() {
    document.execCommand('italic', false, null);
};

// 设置下标
RE.setSubscript = function() {
    document.execCommand('subscript', false, null);
};

// 设置上标
RE.setSuperscript = function() {
    document.execCommand('superscript', false, null);
};

// 设置删除线
RE.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
};

// 设置下划线
RE.setUnderline = function() {
    document.execCommand('underline', false, null);
};

// 设置文本颜色
RE.setTextColor = function(color) {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
};

// 设置文本背景颜色
RE.setTextBackgroundColor = function(color) {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
};

// 设置标题
RE.setHeading = function(heading) {
    document.execCommand('formatBlock', false, '<h' + heading + '>');
};

// 增加缩进
RE.setIndent = function() {
    document.execCommand('indent', false, null);
};

// 减少缩进
RE.setOutdent = function() {
    document.execCommand('outdent', false, null);
};

// 设置有序列表
RE.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
};

// 设置无序列表
RE.setUnorderedList = function() {
    document.execCommand('insertUnorderedList', false, null);
};

// 设置左对齐
RE.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
};

// 设置居中对齐
RE.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
};

// 设置右对齐
RE.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
};

// 获取行高
RE.getLineHeight = function() {
    return RE.editor.style.lineHeight;
};

// 设置行高
RE.setLineHeight = function(height) {
    RE.editor.style.lineHeight = height;
};

// 插入图片
RE.insertImage = function(url, alt) {
    var img = document.createElement('img');
    img.setAttribute("src", url);
    img.setAttribute("alt", alt);
    img.onload = RE.updateHeight;

    RE.insertHTML(img.outerHTML);
    RE.callback("input");
};

// 设置引用块
RE.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
};

// 插入HTML
RE.insertHTML = function(html) {
    RE.restorerange();
    document.execCommand('insertHTML', false, html);
};

// 插入链接
RE.insertLink = function(url, title) {
    RE.restorerange();
    var sel = document.getSelection();
    if (sel.toString().length !== 0) {
        if (sel.rangeCount) {

            var el = document.createElement("a");
            el.setAttribute("href", url);
            el.setAttribute("title", title);

            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }
    RE.callback("input");
};

// 准备插入
RE.prepareInsert = function() {
    RE.backuprange();
};

// 备份选择范围
RE.backuprange = function() {
    var selection = window.getSelection();
    if (selection.rangeCount > 0) {
        var range = selection.getRangeAt(0);
        RE.currentSelection = {
            "startContainer": range.startContainer,
            "startOffset": range.startOffset,
            "endContainer": range.endContainer,
            "endOffset": range.endOffset
        };
    }
};

// 向选择中添加范围
RE.addRangeToSelection = function(selection, range) {
    if (selection) {
        selection.removeAllRanges();
        selection.addRange(range);
    }
};

// 以编程方式选择DOM元素
RE.selectElementContents = function(el) {
    var range = document.createRange();
    range.selectNodeContents(el);
    var sel = window.getSelection();
    // this.createSelectionFromRange sel, range
    RE.addRangeToSelection(sel, range);
};

// 恢复选择范围
RE.restorerange = function() {
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(RE.currentSelection.startContainer, RE.currentSelection.startOffset);
    range.setEnd(RE.currentSelection.endContainer, RE.currentSelection.endOffset);
    selection.addRange(range);
};

// 聚焦
RE.focus = function() {
    var range = document.createRange();
    range.selectNodeContents(RE.editor);
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

// 在指定点聚焦
RE.focusAtPoint = function(x, y) {
    var range = document.caretRangeFromPoint(x, y) || document.createRange();
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

// 失去焦点
RE.blurFocus = function() {
    RE.editor.blur();
};

/**
递归搜索元素祖先以查找元素nodeName，例如A
**/
var _findNodeByNameInContainer = function(element, nodeName, rootElementId) {
    if (element.nodeName == nodeName) {
        return element;
    } else {
        if (element.id === rootElementId) {
            return null;
        }
        _findNodeByNameInContainer(element.parentElement, nodeName, rootElementId);
    }
};

// 检查节点是否为锚节点
var isAnchorNode = function(node) {
    return ("A" == node.nodeName);
};

// 获取节点中的锚标签
RE.getAnchorTagsInNode = function(node) {
    var links = [];

    while (node.nextSibling !== null && node.nextSibling !== undefined) {
        node = node.nextSibling;
        if (isAnchorNode(node)) {
            links.push(node.getAttribute('href'));
        }
    }
    return links;
};

// 计算节点中锚标签的数量
RE.countAnchorTagsInNode = function(node) {
    return RE.getAnchorTagsInNode(node).length;
};

/**
 * 如果当前选择的父级是锚标签，则获取href。
 * @returns {string}
 */
RE.getSelectedHref = function() {
    var href, sel;
    href = '';
    sel = window.getSelection();
    if (!RE.rangeOrCaretSelectionExists()) {
        return null;
    }

    var tags = RE.getAnchorTagsInNode(sel.anchorNode);
    //如果有多于一个链接，返回null
    if (tags.length > 1) {
        return null;
    } else if (tags.length == 1) {
        href = tags[0];
    } else {
        var node = _findNodeByNameInContainer(sel.anchorNode.parentElement, 'A', 'editor');
        href = node.href;
    }

    return href ? href : null;
};

// 返回光标位置相对于屏幕上当前位置的坐标
// 如果在可见内容之上，可能为负数
RE.getRelativeCaretYPosition = function() {
    var y = 0;
    var sel = window.getSelection();
    if (sel.rangeCount) {
        var range = sel.getRangeAt(0);
        var needsWorkAround = (range.startOffset == 0)
        /* 移除修复节点名称不是'div'时的bug */
        // && range.startContainer.nodeName.toLowerCase() == 'div');
        if (needsWorkAround) {
            y = range.startContainer.offsetTop - window.pageYOffset;
        } else {
            if (range.getClientRects) {
                var rects = range.getClientRects();
                if (rects.length > 0) {
                    y = rects[0].top;
                }
            }
        }
    }

    return y;
};

// 页面加载完成后调用
window.onload = function() {
    RE.callback("ready");
};
