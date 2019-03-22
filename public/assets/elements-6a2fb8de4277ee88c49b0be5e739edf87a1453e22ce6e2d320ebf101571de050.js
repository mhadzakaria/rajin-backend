/*
 * HTML5Sortable package
 * https://github.com/lukasoppermann/html5sortable
 *
 * Maintained by Lukas Oppermann <lukas@vea.re>
 *
 * Released under the MIT license.
 */

var sortable = (function () {
    'use strict';

    /**
     * Get or set data on element
     * @param {HTMLElement} element
     * @param {string} key
     * @param {any} value
     * @return {*}
     */
    function addData(element, key, value) {
        if (value === undefined) {
            return element && element.h5s && element.h5s.data && element.h5s.data[key];
        }
        else {
            element.h5s = element.h5s || {};
            element.h5s.data = element.h5s.data || {};
            element.h5s.data[key] = value;
        }
    }
    /**
     * Remove data from element
     * @param {HTMLElement} element
     */
    function removeData(element) {
        if (element.h5s) {
            delete element.h5s.data;
        }
    }

    function _filter (nodes, selector) {
        if (!(nodes instanceof NodeList || nodes instanceof HTMLCollection || nodes instanceof Array)) {
            throw new Error('You must provide a nodeList/HTMLCollection/Array of elements to be filtered.');
        }
        if (typeof selector !== 'string') {
            return Array.from(nodes);
        }
        return Array.from(nodes).filter(function (item) { return item.nodeType === 1 && item.matches(selector); });
    }

    /* eslint-env browser */
    var stores = new Map();
    /**
     * Stores data & configurations per Sortable
     * @param {Object} config
     */
    var Store = (function () {
        function Store() {
            this._config = new Map(); // eslint-disable-line no-undef
            this._placeholder = undefined; // eslint-disable-line no-undef
            this._data = new Map(); // eslint-disable-line no-undef
        }
        Object.defineProperty(Store.prototype, "config", {
            /**
             * get the configuration map of a class instance
             * @method config
             * @return {object}
             */
            get: function () {
                // transform Map to object
                var config = {};
                this._config.forEach(function (value, key) {
                    config[key] = value;
                });
                // return object
                return config;
            },
            /**
             * set the configuration of a class instance
             * @method config
             * @param {object} config object of configurations
             */
            set: function (config) {
                if (typeof config !== 'object') {
                    throw new Error('You must provide a valid configuration object to the config setter.');
                }
                // combine config with default
                var mergedConfig = Object.assign({}, config);
                // add config to map
                this._config = new Map(Object.entries(mergedConfig));
            },
            enumerable: true,
            configurable: true
        });
        /**
         * set individual configuration of a class instance
         * @method setConfig
         * @param  key valid configuration key
         * @param  value any value
         * @return void
         */
        Store.prototype.setConfig = function (key, value) {
            if (!this._config.has(key)) {
                throw new Error("Trying to set invalid configuration item: " + key);
            }
            // set config
            this._config.set(key, value);
        };
        /**
         * get an individual configuration of a class instance
         * @method getConfig
         * @param  key valid configuration key
         * @return any configuration value
         */
        Store.prototype.getConfig = function (key) {
            if (!this._config.has(key)) {
                throw new Error("Invalid configuration item requested: " + key);
            }
            return this._config.get(key);
        };
        Object.defineProperty(Store.prototype, "placeholder", {
            /**
             * get the placeholder for a class instance
             * @method placeholder
             * @return {HTMLElement|null}
             */
            get: function () {
                return this._placeholder;
            },
            /**
             * set the placeholder for a class instance
             * @method placeholder
             * @param {HTMLElement} placeholder
             * @return {void}
             */
            set: function (placeholder) {
                if (!(placeholder instanceof HTMLElement) && placeholder !== null) {
                    throw new Error('A placeholder must be an html element or null.');
                }
                this._placeholder = placeholder;
            },
            enumerable: true,
            configurable: true
        });
        /**
         * set an data entry
         * @method setData
         * @param {string} key
         * @param {any} value
         * @return {void}
         */
        Store.prototype.setData = function (key, value) {
            if (typeof key !== 'string') {
                throw new Error("The key must be a string.");
            }
            this._data.set(key, value);
        };
        /**
         * get an data entry
         * @method getData
         * @param {string} key an existing key
         * @return {any}
         */
        Store.prototype.getData = function (key) {
            if (typeof key !== 'string') {
                throw new Error("The key must be a string.");
            }
            return this._data.get(key);
        };
        /**
         * delete an data entry
         * @method deleteData
         * @param {string} key an existing key
         * @return {boolean}
         */
        Store.prototype.deleteData = function (key) {
            if (typeof key !== 'string') {
                throw new Error("The key must be a string.");
            }
            return this._data.delete(key);
        };
        return Store;
    }());
    function store (sortableElement) {
        // if sortableElement is wrong type
        if (!(sortableElement instanceof HTMLElement)) {
            throw new Error('Please provide a sortable to the store function.');
        }
        // create new instance if not avilable
        if (!stores.has(sortableElement)) {
            stores.set(sortableElement, new Store());
        }
        // return instance
        return stores.get(sortableElement);
    }

    /**
     * @param {Array|HTMLElement} element
     * @param {Function} callback
     * @param {string} event
     */
    function addEventListener(element, eventName, callback) {
        if (element instanceof Array) {
            for (var i = 0; i < element.length; ++i) {
                addEventListener(element[i], eventName, callback);
            }
            return;
        }
        element.addEventListener(eventName, callback);
        store(element).setData("event" + eventName, callback);
    }
    /**
     * @param {Array<HTMLElement>|HTMLElement} element
     * @param {string} eventName
     */
    function removeEventListener(element, eventName) {
        if (element instanceof Array) {
            for (var i = 0; i < element.length; ++i) {
                removeEventListener(element[i], eventName);
            }
            return;
        }
        element.removeEventListener(eventName, store(element).getData("event" + eventName));
        store(element).deleteData("event" + eventName);
    }

    /**
     * @param {Array<HTMLElement>|HTMLElement} element
     * @param {string} attribute
     * @param {string} value
     */
    function addAttribute(element, attribute, value) {
        if (element instanceof Array) {
            for (var i = 0; i < element.length; ++i) {
                addAttribute(element[i], attribute, value);
            }
            return;
        }
        element.setAttribute(attribute, value);
    }
    /**
     * @param {Array|HTMLElement} element
     * @param {string} attribute
     */
    function removeAttribute(element, attribute) {
        if (element instanceof Array) {
            for (var i = 0; i < element.length; ++i) {
                removeAttribute(element[i], attribute);
            }
            return;
        }
        element.removeAttribute(attribute);
    }

    function offset (element) {
        if (!element.parentElement || element.getClientRects().length === 0) {
            throw new Error('target element must be part of the dom');
        }
        var rect = element.getClientRects()[0];
        return {
            left: rect.left + window.pageXOffset,
            right: rect.right + window.pageXOffset,
            top: rect.top + window.pageYOffset,
            bottom: rect.bottom + window.pageYOffset
        };
    }

    function _debounce (func, wait) {
        if (wait === void 0) { wait = 0; }
        var timeout;
        return function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i - 0] = arguments[_i];
            }
            clearTimeout(timeout);
            timeout = setTimeout(function () {
                func.apply(void 0, args);
            }, wait);
        };
    }

    function index (element, elementList) {
        if (!(element instanceof HTMLElement) || !(elementList instanceof NodeList || elementList instanceof HTMLCollection || elementList instanceof Array)) {
            throw new Error('You must provide an element and a list of elements.');
        }
        return Array.from(elementList).indexOf(element);
    }

    function isInDom (element) {
        if (!(element instanceof HTMLElement)) {
            throw new Error('Element is not a node element.');
        }
        return element.parentNode !== null;
    }

    /* eslint-env browser */
    /**
     * Insert node before or after target
     * @param {HTMLElement} referenceNode - reference element
     * @param {HTMLElement} newElement - element to be inserted
     * @param {String} position - insert before or after reference element
     */
    var insertNode = function (referenceNode, newElement, position) {
        if (!(referenceNode instanceof HTMLElement) || !(referenceNode.parentElement instanceof HTMLElement)) {
            throw new Error('target and element must be a node');
        }
        referenceNode.parentElement.insertBefore(newElement, (position === 'before' ? referenceNode : referenceNode.nextElementSibling));
    };
    /**
     * Insert before target
     * @param {HTMLElement} target
     * @param {HTMLElement} element
     */
    var insertBefore = function (target, element) { return insertNode(target, element, 'before'); };
    /**
     * Insert after target
     * @param {HTMLElement} target
     * @param {HTMLElement} element
     */
    var insertAfter = function (target, element) { return insertNode(target, element, 'after'); };

    function _serialize (sortableContainer, customItemSerializer, customContainerSerializer) {
        if (customItemSerializer === void 0) { customItemSerializer = function (serializedItem, sortableContainer) { return serializedItem; }; }
        if (customContainerSerializer === void 0) { customContainerSerializer = function (serializedContainer) { return serializedContainer; }; }
        // check for valid sortableContainer
        if (!(sortableContainer instanceof HTMLElement) || !sortableContainer.isSortable === true) {
            throw new Error('You need to provide a sortableContainer to be serialized.');
        }
        // check for valid serializers
        if (typeof customItemSerializer !== 'function' || typeof customContainerSerializer !== 'function') {
            throw new Error('You need to provide a valid serializer for items and the container.');
        }
        // get options
        var options = addData(sortableContainer, 'opts');
        var item = options.items;
        // serialize container
        var items = _filter(sortableContainer.children, item);
        var serializedItems = items.map(function (item) {
            return {
                parent: sortableContainer,
                node: item,
                html: item.outerHTML,
                index: index(item, items)
            };
        });
        // serialize container
        var container = {
            node: sortableContainer,
            itemCount: serializedItems.length
        };
        return {
            container: customContainerSerializer(container),
            items: serializedItems.map(function (item) { return customItemSerializer(item, sortableContainer); })
        };
    }

    function _makePlaceholder (sortableElement, placeholder, placeholderClass) {
        if (placeholderClass === void 0) { placeholderClass = 'sortable-placeholder'; }
        if (!(sortableElement instanceof HTMLElement)) {
            throw new Error('You must provide a valid element as a sortable.');
        }
        // if placeholder is not an element
        if (!(placeholder instanceof HTMLElement) && placeholder !== undefined) {
            throw new Error('You must provide a valid element as a placeholder or set ot to undefined.');
        }
        // if no placeholder element is given
        if (placeholder === undefined) {
            if (['UL', 'OL'].includes(sortableElement.tagName)) {
                placeholder = document.createElement('li');
            }
            else if (['TABLE', 'TBODY'].includes(sortableElement.tagName)) {
                placeholder = document.createElement('tr');
                // set colspan to always all rows, otherwise the item can only be dropped in first column
                placeholder.innerHTML = '<td colspan="100"></td>';
            }
            else {
                placeholder = document.createElement('div');
            }
        }
        // add classes to placeholder
        if (typeof placeholderClass === 'string') {
            (_a = placeholder.classList).add.apply(_a, placeholderClass.split(' '));
        }
        return placeholder;
        var _a;
    }

    function _getElementHeight (element) {
        if (!(element instanceof HTMLElement)) {
            throw new Error('You must provide a valid dom element');
        }
        // get calculated style of element
        var style = window.getComputedStyle(element);
        // pick applicable properties, convert to int and reduce by adding
        return ['height', 'padding-top', 'padding-bottom']
            .map(function (key) {
            var int = parseInt(style.getPropertyValue(key), 10);
            return isNaN(int) ? 0 : int;
        })
            .reduce(function (sum, value) { return sum + value; });
    }

    function _getHandles (items, selector) {
        if (!(items instanceof Array)) {
            throw new Error('You must provide a Array of HTMLElements to be filtered.');
        }
        if (typeof selector !== 'string') {
            return items;
        }
        return items
            .filter(function (item) {
            return item.querySelector(selector) instanceof HTMLElement;
        })
            .map(function (item) {
            return item.querySelector(selector);
        });
    }

    /**
     * defaultDragImage returns the current item as dragged image
     * @param {HTMLElement} draggedElement - the item that the user drags
     * @param {object} elementOffset - an object with the offsets top, left, right & bottom
     * @param {Event} event - the original drag event object
     * @return {object} with element, posX and posY properties
     */
    var defaultDragImage = function (draggedElement, elementOffset, event) {
        return {
            element: draggedElement,
            posX: event.pageX - elementOffset.left,
            posY: event.pageY - elementOffset.top
        };
    };
    function setDragImage (event, draggedElement, customDragImage) {
        // check if event is provided
        if (!(event instanceof Event)) {
            throw new Error('setDragImage requires a DragEvent as the first argument.');
        }
        // check if draggedElement is provided
        if (!(draggedElement instanceof HTMLElement)) {
            throw new Error('setDragImage requires the dragged element as the second argument.');
        }
        // set default function of none provided
        if (!customDragImage) {
            customDragImage = defaultDragImage;
        }
        // check if setDragImage method is available
        if (event.dataTransfer && event.dataTransfer.setDragImage) {
            // get the elements offset
            var elementOffset = offset(draggedElement);
            // get the dragImage
            var dragImage = customDragImage(draggedElement, elementOffset, event);
            // check if custom function returns correct values
            if (!(dragImage.element instanceof HTMLElement) || typeof dragImage.posX !== 'number' || typeof dragImage.posY !== 'number') {
                throw new Error('The customDragImage function you provided must return and object with the properties element[string], posX[integer], posY[integer].');
            }
            // needs to be set for HTML5 drag & drop to work
            event.dataTransfer.effectAllowed = 'copyMove';
            // Firefox requires it to use the event target's id for the data
            event.dataTransfer.setData('text/plain', event.target.id);
            // set the drag image on the event
            event.dataTransfer.setDragImage(dragImage.element, dragImage.posX, dragImage.posY);
        }
    }

    function _listsConnected (destination, origin) {
        // check if valid sortable
        if (destination.isSortable === true) {
            var acceptFrom = store(destination).getConfig('acceptFrom');
            // check if acceptFrom is valid
            if (acceptFrom !== null && acceptFrom !== false && typeof acceptFrom !== 'string') {
                throw new Error('HTML5Sortable: Wrong argument, "acceptFrom" must be "null", "false", or a valid selector string.');
            }
            if (acceptFrom !== null) {
                return acceptFrom !== false && acceptFrom.split(',').filter(function (sel) {
                    return sel.length > 0 && origin.matches(sel);
                }).length > 0;
            }
            // drop in same list
            if (destination === origin) {
                return true;
            }
            // check if lists are connected with connectWith
            if (store(destination).getConfig('connectWith') !== undefined && store(destination).getConfig('connectWith') !== null) {
                return store(destination).getConfig('connectWith') === store(origin).getConfig('connectWith');
            }
        }
        return false;
    }

    var defaultConfiguration = {
        items: null,
        // deprecated
        connectWith: null,
        // deprecated
        disableIEFix: null,
        acceptFrom: null,
        copy: false,
        placeholder: null,
        placeholderClass: 'sortable-placeholder',
        draggingClass: 'sortable-dragging',
        hoverClass: false,
        debounce: 0,
        throttleTime: 100,
        maxItems: 0,
        itemSerializer: undefined,
        containerSerializer: undefined,
        customDragImage: null
    };

    /**
     * make sure a function is only called once within the given amount of time
     * @param {Function} fn the function to throttle
     * @param {number} threshold time limit for throttling
     */
    // must use function to keep this context
    function _throttle (fn, threshold) {
        var _this = this;
        if (threshold === void 0) { threshold = 250; }
        // check function
        if (typeof fn !== 'function') {
            throw new Error('You must provide a function as the first argument for throttle.');
        }
        // check threshold
        if (typeof threshold !== 'number') {
            throw new Error('You must provide a number as the second argument for throttle.');
        }
        var lastEventTimestamp = null;
        return function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i - 0] = arguments[_i];
            }
            var now = Date.now();
            if (lastEventTimestamp === null || now - lastEventTimestamp >= threshold) {
                lastEventTimestamp = now;
                fn.apply(_this, args);
            }
        };
    }

    function enableHoverClass (sortableContainer, enable) {
        if (typeof store(sortableContainer).getConfig('hoverClass') === 'string') {
            var hoverClasses_1 = store(sortableContainer).getConfig('hoverClass').split(' ');
            // add class on hover
            if (enable === true) {
                addEventListener(sortableContainer, 'mousemove', _throttle(function (event) {
                    // check of no mouse button was pressed when mousemove started == no drag
                    if (event.buttons === 0) {
                        _filter(sortableContainer.children, store(sortableContainer).getConfig('items')).forEach(function (item) {
                            if (item !== event.target) {
                                (_a = item.classList).remove.apply(_a, hoverClasses_1);
                            }
                            else {
                                (_b = item.classList).add.apply(_b, hoverClasses_1);
                            }
                            var _a, _b;
                        });
                    }
                }, store(sortableContainer).getConfig('throttleTime')));
                // remove class on leave
                addEventListener(sortableContainer, 'mouseleave', function () {
                    _filter(sortableContainer.children, store(sortableContainer).getConfig('items')).forEach(function (item) {
                        (_a = item.classList).remove.apply(_a, hoverClasses_1);
                        var _a;
                    });
                });
            }
            else {
                removeEventListener(sortableContainer, 'mousemove');
                removeEventListener(sortableContainer, 'mouseleave');
            }
        }
    }

    /* eslint-env browser */
    /*
     * variables global to the plugin
     */
    var dragging;
    var draggingHeight;
    /*
     * Keeps track of the initialy selected list, where 'dragstart' event was triggered
     * It allows us to move the data in between individual Sortable List instances
     */
    // Origin List - data from before any item was changed
    var originContainer;
    var originIndex;
    var originElementIndex;
    var originItemsBeforeUpdate;
    // Destination List - data from before any item was changed
    var destinationItemsBeforeUpdate;
    /**
     * remove event handlers from items
     * @param {Array|NodeList} items
     */
    var _removeItemEvents = function (items) {
        removeEventListener(items, 'dragstart');
        removeEventListener(items, 'dragend');
        removeEventListener(items, 'dragover');
        removeEventListener(items, 'dragenter');
        removeEventListener(items, 'drop');
        removeEventListener(items, 'mouseenter');
        removeEventListener(items, 'mouseleave');
    };
    /**
     * _getDragging returns the current element to drag or
     * a copy of the element.
     * Is Copy Active for sortable
     * @param {HTMLElement} draggedItem - the item that the user drags
     * @param {HTMLElement} sortable a single sortable
     */
    var _getDragging = function (draggedItem, sortable) {
        var ditem = draggedItem;
        if (store(sortable).getConfig('copy') === true) {
            ditem = draggedItem.cloneNode(true);
            addAttribute(ditem, 'aria-copied', 'true');
            draggedItem.parentElement.appendChild(ditem);
            ditem.style.display = 'none';
            ditem.oldDisplay = draggedItem.style.display;
        }
        return ditem;
    };
    /**
     * Remove data from sortable
     * @param {HTMLElement} sortable a single sortable
     */
    var _removeSortableData = function (sortable) {
        removeData(sortable);
        removeAttribute(sortable, 'aria-dropeffect');
    };
    /**
     * Remove data from items
     * @param {Array<HTMLElement>|HTMLElement} items
     */
    var _removeItemData = function (items) {
        removeAttribute(items, 'aria-grabbed');
        removeAttribute(items, 'aria-copied');
        removeAttribute(items, 'draggable');
        removeAttribute(items, 'role');
    };
    /**
     * find sortable from element. travels up parent element until found or null.
     * @param {HTMLElement} element a single sortable
     */
    function findSortable(element) {
        while (element.isSortable !== true) {
            element = element.parentElement;
        }
        return element;
    }
    /**
     * Dragging event is on the sortable element. finds the top child that
     * contains the element.
     * @param {HTMLElement} sortableElement a single sortable
     * @param {HTMLElement} element is that being dragged
     */
    function findDragElement(sortableElement, element) {
        var options = addData(sortableElement, 'opts');
        var items = _filter(sortableElement.children, options.items);
        var itemlist = items.filter(function (ele) {
            return ele.contains(element);
        });
        return itemlist.length > 0 ? itemlist[0] : element;
    }
    /**
     * Destroy the sortable
     * @param {HTMLElement} sortableElement a single sortable
     */
    var _destroySortable = function (sortableElement) {
        var opts = addData(sortableElement, 'opts') || {};
        var items = _filter(sortableElement.children, opts.items);
        var handles = _getHandles(items, opts.handle);
        // remove event handlers & data from sortable
        removeEventListener(sortableElement, 'dragover');
        removeEventListener(sortableElement, 'dragenter');
        removeEventListener(sortableElement, 'drop');
        // remove event data from sortable
        _removeSortableData(sortableElement);
        // remove event handlers & data from items
        removeEventListener(handles, 'mousedown');
        _removeItemEvents(items);
        _removeItemData(items);
    };
    /**
     * Enable the sortable
     * @param {HTMLElement} sortableElement a single sortable
     */
    var _enableSortable = function (sortableElement) {
        var opts = addData(sortableElement, 'opts');
        var items = _filter(sortableElement.children, opts.items);
        var handles = _getHandles(items, opts.handle);
        addAttribute(sortableElement, 'aria-dropeffect', 'move');
        addData(sortableElement, '_disabled', 'false');
        addAttribute(handles, 'draggable', 'true');
        // @todo: remove this fix
        // IE FIX for ghost
        // can be disabled as it has the side effect that other events
        // (e.g. click) will be ignored
        if (opts.disableIEFix === false) {
            var spanEl = (document || window.document).createElement('span');
            if (typeof spanEl.dragDrop === 'function') {
                addEventListener(handles, 'mousedown', function () {
                    if (items.indexOf(this) !== -1) {
                        this.dragDrop();
                    }
                    else {
                        var parent = this.parentElement;
                        while (items.indexOf(parent) === -1) {
                            parent = parent.parentElement;
                        }
                        parent.dragDrop();
                    }
                });
            }
        }
    };
    /**
     * Disable the sortable
     * @param {HTMLElement} sortableElement a single sortable
     */
    var _disableSortable = function (sortableElement) {
        var opts = addData(sortableElement, 'opts');
        var items = _filter(sortableElement.children, opts.items);
        var handles = _getHandles(items, opts.handle);
        addAttribute(sortableElement, 'aria-dropeffect', 'none');
        addData(sortableElement, '_disabled', 'true');
        addAttribute(handles, 'draggable', 'false');
        removeEventListener(handles, 'mousedown');
    };
    /**
     * Reload the sortable
     * @param {HTMLElement} sortableElement a single sortable
     * @description events need to be removed to not be double bound
     */
    var _reloadSortable = function (sortableElement) {
        var opts = addData(sortableElement, 'opts');
        var items = _filter(sortableElement.children, opts.items);
        var handles = _getHandles(items, opts.handle);
        addData(sortableElement, '_disabled', 'false');
        // remove event handlers from items
        _removeItemEvents(items);
        removeEventListener(handles, 'mousedown');
        // remove event handlers from sortable
        removeEventListener(sortableElement, 'dragover');
        removeEventListener(sortableElement, 'dragenter');
        removeEventListener(sortableElement, 'drop');
    };
    /**
     * Public sortable object
     * @param {Array|NodeList} sortableElements
     * @param {object|string} options|method
     */
    function sortable(sortableElements, options) {
        // get method string to see if a method is called
        var method = String(options);
        options = options || {};
        // check if the user provided a selector instead of an element
        if (typeof sortableElements === 'string') {
            sortableElements = document.querySelectorAll(sortableElements);
        }
        // if the user provided an element, return it in an array to keep the return value consistant
        if (sortableElements instanceof HTMLElement) {
            sortableElements = [sortableElements];
        }
        sortableElements = Array.prototype.slice.call(sortableElements);
        if (/serialize/.test(method)) {
            return sortableElements.map(function (sortableContainer) {
                var opts = addData(sortableContainer, 'opts');
                return _serialize(sortableContainer, opts.itemSerializer, opts.containerSerializer);
            });
        }
        sortableElements.forEach(function (sortableElement) {
            if (/enable|disable|destroy/.test(method)) {
                return sortable[method](sortableElement);
            }
            // log deprecation
            ['connectWith', 'disableIEFix'].forEach(function (configKey) {
                if (options.hasOwnProperty(configKey) && options[configKey] !== null) {
                    console.warn("HTML5Sortable: You are using the deprecated configuration \"" + configKey + "\". This will be removed in an upcoming version, make sure to migrate to the new options when updating.");
                }
            });
            // merge options with default options
            options = Object.assign({}, defaultConfiguration, store(sortableElement).config, options);
            // init data store for sortable
            store(sortableElement).config = options;
            // set options on sortable
            addData(sortableElement, 'opts', options);
            // property to define as sortable
            sortableElement.isSortable = true;
            // reset sortable
            _reloadSortable(sortableElement);
            // initialize
            var listItems = _filter(sortableElement.children, options.items);
            // create element if user defined a placeholder element as a string
            var customPlaceholder;
            if (options.placeholder !== null && options.placeholder !== undefined) {
                var tempContainer = document.createElement(sortableElement.tagName);
                tempContainer.innerHTML = options.placeholder;
                customPlaceholder = tempContainer.children[0];
            }
            // add placeholder
            store(sortableElement).placeholder = _makePlaceholder(sortableElement, customPlaceholder, options.placeholderClass);
            addData(sortableElement, 'items', options.items);
            if (options.acceptFrom) {
                addData(sortableElement, 'acceptFrom', options.acceptFrom);
            }
            else if (options.connectWith) {
                addData(sortableElement, 'connectWith', options.connectWith);
            }
            _enableSortable(sortableElement);
            addAttribute(listItems, 'role', 'option');
            addAttribute(listItems, 'aria-grabbed', 'false');
            // enable hover class
            enableHoverClass(sortableElement, true);
            /*
             Handle drag events on draggable items
             Handle is set at the sortableElement level as it will bubble up
             from the item
             */
            addEventListener(sortableElement, 'dragstart', function (e) {
                // ignore dragstart events
                if (e.target.isSortable === true) {
                    return;
                }
                e.stopImmediatePropagation();
                if ((options.handle && !e.target.matches(options.handle)) || e.target.getAttribute('draggable') === 'false') {
                    return;
                }
                var sortableContainer = findSortable(e.target);
                var dragItem = findDragElement(sortableContainer, e.target);
                // grab values
                originItemsBeforeUpdate = _filter(sortableContainer.children, options.items);
                originIndex = originItemsBeforeUpdate.indexOf(dragItem);
                originElementIndex = index(dragItem, sortableContainer.children);
                originContainer = sortableContainer;
                // add transparent clone or other ghost to cursor
                setDragImage(e, dragItem, options.customDragImage);
                // cache selsection & add attr for dragging
                draggingHeight = _getElementHeight(dragItem);
                dragItem.classList.add(options.draggingClass);
                dragging = _getDragging(dragItem, sortableContainer);
                addAttribute(dragging, 'aria-grabbed', 'true');
                // dispatch sortstart event on each element in group
                sortableContainer.dispatchEvent(new CustomEvent('sortstart', {
                    detail: {
                        origin: {
                            elementIndex: originElementIndex,
                            index: originIndex,
                            container: originContainer
                        },
                        item: dragging
                    }
                }));
            });
            /*
             We are capturing targetSortable before modifications with 'dragenter' event
            */
            addEventListener(sortableElement, 'dragenter', function (e) {
                if (e.target.isSortable === true) {
                    return;
                }
                var sortableContainer = findSortable(e.target);
                destinationItemsBeforeUpdate = _filter(sortableContainer.children, addData(sortableContainer, 'items'))
                    .filter(function (item) { return item !== store(sortableElement).placeholder; });
            });
            /*
             * Dragend Event - https://developer.mozilla.org/en-US/docs/Web/Events/dragend
             * Fires each time dragEvent end, or ESC pressed
             * We are using it to clean up any draggable elements and placeholders
             */
            addEventListener(sortableElement, 'dragend', function (e) {
                if (!dragging) {
                    return;
                }
                dragging.classList.remove(options.draggingClass);
                addAttribute(dragging, 'aria-grabbed', 'false');
                if (dragging.getAttribute('aria-copied') === 'true' && addData(dragging, 'dropped') !== 'true') {
                    dragging.remove();
                }
                dragging.style.display = dragging.oldDisplay;
                delete dragging.oldDisplay;
                var visiblePlaceholder = Array.from(stores.values()).map(function (data) { return data.placeholder; })
                    .filter(function (placeholder) { return placeholder instanceof HTMLElement; })
                    .filter(isInDom)[0];
                if (visiblePlaceholder) {
                    visiblePlaceholder.remove();
                }
                // dispatch sortstart event on each element in group
                sortableElement.dispatchEvent(new CustomEvent('sortstop', {
                    detail: {
                        origin: {
                            elementIndex: originElementIndex,
                            index: originIndex,
                            container: originContainer
                        },
                        item: dragging
                    }
                }));
                dragging = null;
                draggingHeight = null;
            });
            /*
             * Drop Event - https://developer.mozilla.org/en-US/docs/Web/Events/drop
             * Fires when valid drop target area is hit
             */
            addEventListener(sortableElement, 'drop', function (e) {
                if (!_listsConnected(sortableElement, dragging.parentElement)) {
                    return;
                }
                e.preventDefault();
                e.stopPropagation();
                addData(dragging, 'dropped', 'true');
                // get the one placeholder that is currently visible
                var visiblePlaceholder = Array.from(stores.values()).map(function (data) {
                    return data.placeholder;
                })
                    .filter(function (placeholder) { return placeholder instanceof HTMLElement; })
                    .filter(isInDom)[0];
                // attach element after placeholder
                insertAfter(visiblePlaceholder, dragging);
                // remove placeholder from dom
                visiblePlaceholder.remove();
                /*
                 * Fires Custom Event - 'sortstop'
                 */
                sortableElement.dispatchEvent(new CustomEvent('sortstop', {
                    detail: {
                        origin: {
                            elementIndex: originElementIndex,
                            index: originIndex,
                            container: originContainer
                        },
                        item: dragging
                    }
                }));
                var placeholder = store(sortableElement).placeholder;
                var originItems = _filter(originContainer.children, options.items)
                    .filter(function (item) { return item !== placeholder; });
                var destinationContainer = this.isSortable === true ? this : this.parentElement;
                var destinationItems = _filter(destinationContainer.children, addData(destinationContainer, 'items'))
                    .filter(function (item) { return item !== placeholder; });
                var destinationElementIndex = index(dragging, Array.from(dragging.parentElement.children)
                    .filter(function (item) { return item !== placeholder; }));
                var destinationIndex = index(dragging, destinationItems);
                /*
                 * When a list item changed container lists or index within a list
                 * Fires Custom Event - 'sortupdate'
                 */
                if (originElementIndex !== destinationElementIndex || originContainer !== destinationContainer) {
                    sortableElement.dispatchEvent(new CustomEvent('sortupdate', {
                        detail: {
                            origin: {
                                elementIndex: originElementIndex,
                                index: originIndex,
                                container: originContainer,
                                itemsBeforeUpdate: originItemsBeforeUpdate,
                                items: originItems
                            },
                            destination: {
                                index: destinationIndex,
                                elementIndex: destinationElementIndex,
                                container: destinationContainer,
                                itemsBeforeUpdate: destinationItemsBeforeUpdate,
                                items: destinationItems
                            },
                            item: dragging
                        }
                    }));
                }
            });
            var debouncedDragOverEnter = _debounce(function (sortableElement, element, pageY) {
                if (!dragging) {
                    return;
                }
                // set placeholder height if forcePlaceholderSize option is set
                if (options.forcePlaceholderSize) {
                    store(sortableElement).placeholder.style.height = draggingHeight + 'px';
                }
                // if element the draggedItem is dragged onto is within the array of all elements in list
                // (not only items, but also disabled, etc.)
                if (Array.from(sortableElement.children).indexOf(element) > -1) {
                    var thisHeight = _getElementHeight(element);
                    var placeholderIndex = index(store(sortableElement).placeholder, element.parentElement.children);
                    var thisIndex = index(element, element.parentElement.children);
                    // Check if `element` is bigger than the draggable. If it is, we have to define a dead zone to prevent flickering
                    if (thisHeight > draggingHeight) {
                        // Dead zone?
                        var deadZone = thisHeight - draggingHeight;
                        var offsetTop = offset(element).top;
                        if (placeholderIndex < thisIndex && pageY < offsetTop) {
                            return;
                        }
                        if (placeholderIndex > thisIndex &&
                            pageY > offsetTop + thisHeight - deadZone) {
                            return;
                        }
                    }
                    if (dragging.oldDisplay === undefined) {
                        dragging.oldDisplay = dragging.style.display;
                    }
                    if (dragging.style.display !== 'none') {
                        dragging.style.display = 'none';
                    }
                    // To avoid flicker, determine where to position the placeholder
                    // based on where the mouse pointer is relative to the elements
                    // vertical center.
                    var placeAfter = false;
                    try {
                        var elementMiddle = offset(element).top + element.offsetHeight / 2;
                        placeAfter = pageY >= elementMiddle;
                    }
                    catch (e) {
                        placeAfter = placeholderIndex < thisIndex;
                    }
                    if (placeAfter) {
                        insertAfter(element, store(sortableElement).placeholder);
                    }
                    else {
                        insertBefore(element, store(sortableElement).placeholder);
                    }
                    // get placeholders from all stores & remove all but current one
                    Array.from(stores.values())
                        .filter(function (data) { return data.placeholder !== undefined; })
                        .forEach(function (data) {
                        if (data.placeholder !== store(sortableElement).placeholder) {
                            data.placeholder.remove();
                        }
                    });
                }
                else {
                    // get all placeholders from store
                    var placeholders = Array.from(stores.values())
                        .filter(function (data) { return data.placeholder !== undefined; })
                        .map(function (data) {
                        return data.placeholder;
                    });
                    // check if element is not in placeholders
                    if (placeholders.indexOf(element) === -1 && sortableElement === element && !_filter(element.children, options.items).length) {
                        placeholders.forEach(function (element) { return element.remove(); });
                        element.appendChild(store(sortableElement).placeholder);
                    }
                }
            }, options.debounce);
            // Handle dragover and dragenter events on draggable items
            var onDragOverEnter = function (e) {
                var element = e.target;
                var sortableElement = element.isSortable === true ? element : findSortable(element);
                element = findDragElement(sortableElement, element);
                if (!dragging || !_listsConnected(sortableElement, dragging.parentElement) || addData(sortableElement, '_disabled') === 'true') {
                    return;
                }
                var options = addData(sortableElement, 'opts');
                if (parseInt(options.maxItems) && _filter(sortableElement.children, addData(sortableElement, 'items')).length >= parseInt(options.maxItems) && dragging.parentElement !== sortableElement) {
                    return;
                }
                e.preventDefault();
                e.stopPropagation();
                e.dataTransfer.dropEffect = store(sortableElement).getConfig('copy') === true ? 'copy' : 'move';
                debouncedDragOverEnter(sortableElement, element, e.pageY);
            };
            addEventListener(listItems.concat(sortableElement), 'dragover', onDragOverEnter);
            addEventListener(listItems.concat(sortableElement), 'dragenter', onDragOverEnter);
        });
        return sortableElements;
    }
    sortable.destroy = function (sortableElement) {
        _destroySortable(sortableElement);
    };
    sortable.enable = function (sortableElement) {
        _enableSortable(sortableElement);
    };
    sortable.disable = function (sortableElement) {
        _disableSortable(sortableElement);
    };

    return sortable;

}());
/*!
 * Nestable jQuery Plugin - Copyright (c) 2012 David Bushell - http://dbushell.com/
 * Dual-licensed under the BSD or MIT licenses
 */

;(function($, window, document, undefined)
{
    var hasTouch = 'ontouchstart' in document;

    /**
     * Detect CSS pointer-events property
     * events are normally disabled on the dragging element to avoid conflicts
     * https://github.com/ausi/Feature-detection-technique-for-pointer-events/blob/master/modernizr-pointerevents.js
     */
    var hasPointerEvents = (function()
    {
        var el    = document.createElement('div'),
            docEl = document.documentElement;
        if (!('pointerEvents' in el.style)) {
            return false;
        }
        el.style.pointerEvents = 'auto';
        el.style.pointerEvents = 'x';
        docEl.appendChild(el);
        var supports = window.getComputedStyle && window.getComputedStyle(el, '').pointerEvents === 'auto';
        docEl.removeChild(el);
        return !!supports;
    })();

    var defaults = {
            listNodeName    : 'ol',
            itemNodeName    : 'li',
            rootClass       : 'dd',
            listClass       : 'dd-list',
            itemClass       : 'dd-item',
            dragClass       : 'dd-dragel',
            handleClass     : 'dd-handle',
            collapsedClass  : 'dd-collapsed',
            placeClass      : 'dd-placeholder',
            noDragClass     : 'dd-nodrag',
            emptyClass      : 'dd-empty',
            expandBtnHTML   : '<button data-action="expand" type="button">Expand</button>',
            collapseBtnHTML : '<button data-action="collapse" type="button">Collapse</button>',
            group           : 0,
            maxDepth        : 5,
            threshold       : 20
        };

    function Plugin(element, options)
    {
        this.w  = $(document);
        this.el = $(element);
        this.options = $.extend({}, defaults, options);
        this.init();
    }

    Plugin.prototype = {

        init: function()
        {
            var list = this;

            list.reset();

            list.el.data('nestable-group', this.options.group);

            list.placeEl = $('<div class="' + list.options.placeClass + '"/>');

            $.each(this.el.find(list.options.itemNodeName), function(k, el) {
                list.setParent($(el));
            });

            list.el.on('click', 'button', function(e) {
                if (list.dragEl) {
                    return;
                }
                var target = $(e.currentTarget),
                    action = target.data('action'),
                    item   = target.parent(list.options.itemNodeName);
                if (action === 'collapse') {
                    list.collapseItem(item);
                }
                if (action === 'expand') {
                    list.expandItem(item);
                }
            });

            var onStartEvent = function(e)
            {
                var handle = $(e.target);
                if (!handle.hasClass(list.options.handleClass)) {
                    if (handle.closest('.' + list.options.noDragClass).length) {
                        return;
                    }
                    handle = handle.closest('.' + list.options.handleClass);
                }

                if (!handle.length || list.dragEl) {
                    return;
                }

                list.isTouch = /^touch/.test(e.type);
                if (list.isTouch && e.touches.length !== 1) {
                    return;
                }

                e.preventDefault();
                list.dragStart(e.touches ? e.touches[0] : e);
            };

            var onMoveEvent = function(e)
            {
                if (list.dragEl) {
                    e.preventDefault();
                    list.dragMove(e.touches ? e.touches[0] : e);
                }
            };

            var onEndEvent = function(e)
            {
                if (list.dragEl) {
                    e.preventDefault();
                    list.dragStop(e.touches ? e.touches[0] : e);
                }
            };

            if (hasTouch) {
                list.el[0].addEventListener('touchstart', onStartEvent, false);
                window.addEventListener('touchmove', onMoveEvent, false);
                window.addEventListener('touchend', onEndEvent, false);
                window.addEventListener('touchcancel', onEndEvent, false);
            }

            list.el.on('mousedown', onStartEvent);
            list.w.on('mousemove', onMoveEvent);
            list.w.on('mouseup', onEndEvent);

        },

        serialize: function()
        {
            var data,
                depth = 0,
                list  = this;
                step  = function(level, depth)
                {
                    var array = [ ],
                        items = level.children(list.options.itemNodeName);
                    items.each(function()
                    {
                        var li   = $(this),
                            item = $.extend({}, li.data()),
                            sub  = li.children(list.options.listNodeName);
                        if (sub.length) {
                            item.children = step(sub, depth + 1);
                        }
                        array.push(item);
                    });
                    return array;
                };
            data = step(list.el.find(list.options.listNodeName).first(), depth);
            return data;
        },

        serialise: function()
        {
            return this.serialize();
        },

        reset: function()
        {
            this.mouse = {
                offsetX   : 0,
                offsetY   : 0,
                startX    : 0,
                startY    : 0,
                lastX     : 0,
                lastY     : 0,
                nowX      : 0,
                nowY      : 0,
                distX     : 0,
                distY     : 0,
                dirAx     : 0,
                dirX      : 0,
                dirY      : 0,
                lastDirX  : 0,
                lastDirY  : 0,
                distAxX   : 0,
                distAxY   : 0
            };
            this.isTouch    = false;
            this.moving     = false;
            this.dragEl     = null;
            this.dragRootEl = null;
            this.dragDepth  = 0;
            this.hasNewRoot = false;
            this.pointEl    = null;
        },

        expandItem: function(li)
        {
            li.removeClass(this.options.collapsedClass);
            li.children('[data-action="expand"]').hide();
            li.children('[data-action="collapse"]').show();
            li.children(this.options.listNodeName).show();
        },

        collapseItem: function(li)
        {
            var lists = li.children(this.options.listNodeName);
            if (lists.length) {
                li.addClass(this.options.collapsedClass);
                li.children('[data-action="collapse"]').hide();
                li.children('[data-action="expand"]').show();
                li.children(this.options.listNodeName).hide();
            }
        },

        expandAll: function()
        {
            var list = this;
            list.el.find(list.options.itemNodeName).each(function() {
                list.expandItem($(this));
            });
        },

        collapseAll: function()
        {
            var list = this;
            list.el.find(list.options.itemNodeName).each(function() {
                list.collapseItem($(this));
            });
        },

        setParent: function(li)
        {
            if (li.children(this.options.listNodeName).length) {
                li.prepend($(this.options.expandBtnHTML));
                li.prepend($(this.options.collapseBtnHTML));
            }
            li.children('[data-action="expand"]').hide();
        },

        unsetParent: function(li)
        {
            li.removeClass(this.options.collapsedClass);
            li.children('[data-action]').remove();
            li.children(this.options.listNodeName).remove();
        },

        dragStart: function(e)
        {
            var mouse    = this.mouse,
                target   = $(e.target),
                dragItem = target.closest(this.options.itemNodeName);

            this.placeEl.css('height', dragItem.height());

            mouse.offsetX = e.offsetX !== undefined ? e.offsetX : e.pageX - target.offset().left;
            mouse.offsetY = e.offsetY !== undefined ? e.offsetY : e.pageY - target.offset().top;
            mouse.startX = mouse.lastX = e.pageX;
            mouse.startY = mouse.lastY = e.pageY;

            this.dragRootEl = this.el;

            this.dragEl = $(document.createElement(this.options.listNodeName)).addClass(this.options.listClass + ' ' + this.options.dragClass);
            this.dragEl.css('width', dragItem.width());

            dragItem.after(this.placeEl);
            dragItem[0].parentNode.removeChild(dragItem[0]);
            dragItem.appendTo(this.dragEl);

            $(document.body).append(this.dragEl);
            this.dragEl.css({
                'left' : e.pageX - mouse.offsetX,
                'top'  : e.pageY - mouse.offsetY
            });
            // total depth of dragging item
            var i, depth,
                items = this.dragEl.find(this.options.itemNodeName);
            for (i = 0; i < items.length; i++) {
                depth = $(items[i]).parents(this.options.listNodeName).length;
                if (depth > this.dragDepth) {
                    this.dragDepth = depth;
                }
            }
        },

        dragStop: function(e)
        {
            var el = this.dragEl.children(this.options.itemNodeName).first();
            el[0].parentNode.removeChild(el[0]);
            this.placeEl.replaceWith(el);

            this.dragEl.remove();
            this.el.trigger('change');
            if (this.hasNewRoot) {
                this.dragRootEl.trigger('change');
            }
            this.reset();
        },

        dragMove: function(e)
        {
            var list, parent, prev, next, depth,
                opt   = this.options,
                mouse = this.mouse;

            this.dragEl.css({
                'left' : e.pageX - mouse.offsetX,
                'top'  : e.pageY - mouse.offsetY
            });

            // mouse position last events
            mouse.lastX = mouse.nowX;
            mouse.lastY = mouse.nowY;
            // mouse position this events
            mouse.nowX  = e.pageX;
            mouse.nowY  = e.pageY;
            // distance mouse moved between events
            mouse.distX = mouse.nowX - mouse.lastX;
            mouse.distY = mouse.nowY - mouse.lastY;
            // direction mouse was moving
            mouse.lastDirX = mouse.dirX;
            mouse.lastDirY = mouse.dirY;
            // direction mouse is now moving (on both axis)
            mouse.dirX = mouse.distX === 0 ? 0 : mouse.distX > 0 ? 1 : -1;
            mouse.dirY = mouse.distY === 0 ? 0 : mouse.distY > 0 ? 1 : -1;
            // axis mouse is now moving on
            var newAx   = Math.abs(mouse.distX) > Math.abs(mouse.distY) ? 1 : 0;

            // do nothing on first move
            if (!mouse.moving) {
                mouse.dirAx  = newAx;
                mouse.moving = true;
                return;
            }

            // calc distance moved on this axis (and direction)
            if (mouse.dirAx !== newAx) {
                mouse.distAxX = 0;
                mouse.distAxY = 0;
            } else {
                mouse.distAxX += Math.abs(mouse.distX);
                if (mouse.dirX !== 0 && mouse.dirX !== mouse.lastDirX) {
                    mouse.distAxX = 0;
                }
                mouse.distAxY += Math.abs(mouse.distY);
                if (mouse.dirY !== 0 && mouse.dirY !== mouse.lastDirY) {
                    mouse.distAxY = 0;
                }
            }
            mouse.dirAx = newAx;

            /**
             * move horizontal
             */
            if (mouse.dirAx && mouse.distAxX >= opt.threshold) {
                // reset move distance on x-axis for new phase
                mouse.distAxX = 0;
                prev = this.placeEl.prev(opt.itemNodeName);
                // increase horizontal level if previous sibling exists and is not collapsed
                if (mouse.distX > 0 && prev.length && !prev.hasClass(opt.collapsedClass)) {
                    // cannot increase level when item above is collapsed
                    list = prev.find(opt.listNodeName).last();
                    // check if depth limit has reached
                    depth = this.placeEl.parents(opt.listNodeName).length;
                    if (depth + this.dragDepth <= opt.maxDepth) {
                        // create new sub-level if one doesn't exist
                        if (!list.length) {
                            list = $('<' + opt.listNodeName + '/>').addClass(opt.listClass);
                            list.append(this.placeEl);
                            prev.append(list);
                            this.setParent(prev);
                        } else {
                            // else append to next level up
                            list = prev.children(opt.listNodeName).last();
                            list.append(this.placeEl);
                        }
                    }
                }
                // decrease horizontal level
                if (mouse.distX < 0) {
                    // we can't decrease a level if an item preceeds the current one
                    next = this.placeEl.next(opt.itemNodeName);
                    if (!next.length) {
                        parent = this.placeEl.parent();
                        this.placeEl.closest(opt.itemNodeName).after(this.placeEl);
                        if (!parent.children().length) {
                            this.unsetParent(parent.parent());
                        }
                    }
                }
            }

            var isEmpty = false;

            // find list item under cursor
            if (!hasPointerEvents) {
                this.dragEl[0].style.visibility = 'hidden';
            }
            this.pointEl = $(document.elementFromPoint(e.pageX - document.body.scrollLeft, e.pageY - (window.pageYOffset || document.documentElement.scrollTop)));
            if (!hasPointerEvents) {
                this.dragEl[0].style.visibility = 'visible';
            }
            if (this.pointEl.hasClass(opt.handleClass)) {
                this.pointEl = this.pointEl.parent(opt.itemNodeName);
            }
            if (this.pointEl.hasClass(opt.emptyClass)) {
                isEmpty = true;
            }
            else if (!this.pointEl.length || !this.pointEl.hasClass(opt.itemClass)) {
                return;
            }

            // find parent list of item under cursor
            var pointElRoot = this.pointEl.closest('.' + opt.rootClass),
                isNewRoot   = this.dragRootEl.data('nestable-id') !== pointElRoot.data('nestable-id');

            /**
             * move vertical
             */
            if (!mouse.dirAx || isNewRoot || isEmpty) {
                // check if groups match if dragging over new root
                if (isNewRoot && opt.group !== pointElRoot.data('nestable-group')) {
                    return;
                }
                // check depth limit
                depth = this.dragDepth - 1 + this.pointEl.parents(opt.listNodeName).length;
                if (depth > opt.maxDepth) {
                    return;
                }
                var before = e.pageY < (this.pointEl.offset().top + this.pointEl.height() / 2);
                    parent = this.placeEl.parent();
                // if empty create new list to replace empty placeholder
                if (isEmpty) {
                    list = $(document.createElement(opt.listNodeName)).addClass(opt.listClass);
                    list.append(this.placeEl);
                    this.pointEl.replaceWith(list);
                }
                else if (before) {
                    this.pointEl.before(this.placeEl);
                }
                else {
                    this.pointEl.after(this.placeEl);
                }
                if (!parent.children().length) {
                    this.unsetParent(parent.parent());
                }
                if (!this.dragRootEl.find(opt.itemNodeName).length) {
                    this.dragRootEl.append('<div class="' + opt.emptyClass + '"/>');
                }
                // parent root list has changed
                if (isNewRoot) {
                    this.dragRootEl = pointElRoot;
                    this.hasNewRoot = this.el[0] !== this.dragRootEl[0];
                }
            }
        }

    };

    $.fn.nestable = function(params)
    {
        var lists  = this,
            retval = this;

        lists.each(function()
        {
            var plugin = $(this).data("nestable");

            if (!plugin) {
                $(this).data("nestable", new Plugin(this, params));
                $(this).data("nestable-id", new Date().getTime());
            } else {
                if (typeof params === 'string' && typeof plugin[params] === 'function') {
                    retval = plugin[params]();
                }
            }
        });

        return retval || lists;
    };

})(window.jQuery || window.Zepto, window, document);
!function(t,e){"object"==typeof exports&&"object"==typeof module?module.exports=e():"function"==typeof define&&define.amd?define([],e):"object"==typeof exports?exports.swal=e():t.swal=e()}(this,function(){return function(t){function e(o){if(n[o])return n[o].exports;var r=n[o]={i:o,l:!1,exports:{}};return t[o].call(r.exports,r,r.exports,e),r.l=!0,r.exports}var n={};return e.m=t,e.c=n,e.d=function(t,n,o){e.o(t,n)||Object.defineProperty(t,n,{configurable:!1,enumerable:!0,get:o})},e.n=function(t){var n=t&&t.__esModule?function(){return t.default}:function(){return t};return e.d(n,"a",n),n},e.o=function(t,e){return Object.prototype.hasOwnProperty.call(t,e)},e.p="",e(e.s=8)}([function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o="swal-button";e.CLASS_NAMES={MODAL:"swal-modal",OVERLAY:"swal-overlay",SHOW_MODAL:"swal-overlay--show-modal",MODAL_TITLE:"swal-title",MODAL_TEXT:"swal-text",ICON:"swal-icon",ICON_CUSTOM:"swal-icon--custom",CONTENT:"swal-content",FOOTER:"swal-footer",BUTTON_CONTAINER:"swal-button-container",BUTTON:o,CONFIRM_BUTTON:o+"--confirm",CANCEL_BUTTON:o+"--cancel",DANGER_BUTTON:o+"--danger",BUTTON_LOADING:o+"--loading",BUTTON_LOADER:o+"__loader"},e.default=e.CLASS_NAMES},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0}),e.getNode=function(t){var e="."+t;return document.querySelector(e)},e.stringToNode=function(t){var e=document.createElement("div");return e.innerHTML=t.trim(),e.firstChild},e.insertAfter=function(t,e){var n=e.nextSibling;e.parentNode.insertBefore(t,n)},e.removeNode=function(t){t.parentElement.removeChild(t)},e.throwErr=function(t){throw t=t.replace(/ +(?= )/g,""),"SweetAlert: "+(t=t.trim())},e.isPlainObject=function(t){if("[object Object]"!==Object.prototype.toString.call(t))return!1;var e=Object.getPrototypeOf(t);return null===e||e===Object.prototype},e.ordinalSuffixOf=function(t){var e=t%10,n=t%100;return 1===e&&11!==n?t+"st":2===e&&12!==n?t+"nd":3===e&&13!==n?t+"rd":t+"th"}},function(t,e,n){"use strict";function o(t){for(var n in t)e.hasOwnProperty(n)||(e[n]=t[n])}Object.defineProperty(e,"__esModule",{value:!0}),o(n(25));var r=n(26);e.overlayMarkup=r.default,o(n(27)),o(n(28)),o(n(29));var i=n(0),a=i.default.MODAL_TITLE,s=i.default.MODAL_TEXT,c=i.default.ICON,l=i.default.FOOTER;e.iconMarkup='\n  <div class="'+c+'"></div>',e.titleMarkup='\n  <div class="'+a+'"></div>\n',e.textMarkup='\n  <div class="'+s+'"></div>',e.footerMarkup='\n  <div class="'+l+'"></div>\n'},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1);e.CONFIRM_KEY="confirm",e.CANCEL_KEY="cancel";var r={visible:!0,text:null,value:null,className:"",closeModal:!0},i=Object.assign({},r,{visible:!1,text:"Cancel",value:null}),a=Object.assign({},r,{text:"OK",value:!0});e.defaultButtonList={cancel:i,confirm:a};var s=function(t){switch(t){case e.CONFIRM_KEY:return a;case e.CANCEL_KEY:return i;default:var n=t.charAt(0).toUpperCase()+t.slice(1);return Object.assign({},r,{text:n,value:t})}},c=function(t,e){var n=s(t);return!0===e?Object.assign({},n,{visible:!0}):"string"==typeof e?Object.assign({},n,{visible:!0,text:e}):o.isPlainObject(e)?Object.assign({visible:!0},n,e):Object.assign({},n,{visible:!1})},l=function(t){for(var e={},n=0,o=Object.keys(t);n<o.length;n++){var r=o[n],a=t[r],s=c(r,a);e[r]=s}return e.cancel||(e.cancel=i),e},u=function(t){var n={};switch(t.length){case 1:n[e.CANCEL_KEY]=Object.assign({},i,{visible:!1});break;case 2:n[e.CANCEL_KEY]=c(e.CANCEL_KEY,t[0]),n[e.CONFIRM_KEY]=c(e.CONFIRM_KEY,t[1]);break;default:o.throwErr("Invalid number of 'buttons' in array ("+t.length+").\n      If you want more than 2 buttons, you need to use an object!")}return n};e.getButtonListOpts=function(t){var n=e.defaultButtonList;return"string"==typeof t?n[e.CONFIRM_KEY]=c(e.CONFIRM_KEY,t):Array.isArray(t)?n=u(t):o.isPlainObject(t)?n=l(t):!0===t?n=u([!0,!0]):!1===t?n=u([!1,!1]):void 0===t&&(n=e.defaultButtonList),n}},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),r=n(2),i=n(0),a=i.default.MODAL,s=i.default.OVERLAY,c=n(30),l=n(31),u=n(32),f=n(33);e.injectElIntoModal=function(t){var e=o.getNode(a),n=o.stringToNode(t);return e.appendChild(n),n};var d=function(t){t.className=a,t.textContent=""},p=function(t,e){d(t);var n=e.className;n&&t.classList.add(n)};e.initModalContent=function(t){var e=o.getNode(a);p(e,t),c.default(t.icon),l.initTitle(t.title),l.initText(t.text),f.default(t.content),u.default(t.buttons,t.dangerMode)};var m=function(){var t=o.getNode(s),e=o.stringToNode(r.modalMarkup);t.appendChild(e)};e.default=m},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(3),r={isOpen:!1,promise:null,actions:{},timer:null},i=Object.assign({},r);e.resetState=function(){i=Object.assign({},r)},e.setActionValue=function(t){if("string"==typeof t)return a(o.CONFIRM_KEY,t);for(var e in t)a(e,t[e])};var a=function(t,e){i.actions[t]||(i.actions[t]={}),Object.assign(i.actions[t],{value:e})};e.setActionOptionsFor=function(t,e){var n=(void 0===e?{}:e).closeModal,o=void 0===n||n;Object.assign(i.actions[t],{closeModal:o})},e.default=i},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),r=n(3),i=n(0),a=i.default.OVERLAY,s=i.default.SHOW_MODAL,c=i.default.BUTTON,l=i.default.BUTTON_LOADING,u=n(5);e.openModal=function(){o.getNode(a).classList.add(s),u.default.isOpen=!0};var f=function(){o.getNode(a).classList.remove(s),u.default.isOpen=!1};e.onAction=function(t){void 0===t&&(t=r.CANCEL_KEY);var e=u.default.actions[t],n=e.value;if(!1===e.closeModal){var i=c+"--"+t;o.getNode(i).classList.add(l)}else f();u.default.promise.resolve(n)},e.getState=function(){var t=Object.assign({},u.default);return delete t.promise,delete t.timer,t},e.stopLoading=function(){for(var t=document.querySelectorAll("."+c),e=0;e<t.length;e++){t[e].classList.remove(l)}}},function(t,e){var n;n=function(){return this}();try{n=n||Function("return this")()||(0,eval)("this")}catch(t){"object"==typeof window&&(n=window)}t.exports=n},function(t,e,n){(function(e){t.exports=e.sweetAlert=n(9)}).call(e,n(7))},function(t,e,n){(function(e){t.exports=e.swal=n(10)}).call(e,n(7))},function(t,e,n){"undefined"!=typeof window&&n(11),n(16);var o=n(23).default;t.exports=o},function(t,e,n){var o=n(12);"string"==typeof o&&(o=[[t.i,o,""]]);var r={insertAt:"top"};r.transform=void 0;n(14)(o,r);o.locals&&(t.exports=o.locals)},function(t,e,n){e=t.exports=n(13)(void 0),e.push([t.i,'.swal-icon--error{border-color:#f27474;-webkit-animation:animateErrorIcon .5s;animation:animateErrorIcon .5s}.swal-icon--error__x-mark{position:relative;display:block;-webkit-animation:animateXMark .5s;animation:animateXMark .5s}.swal-icon--error__line{position:absolute;height:5px;width:47px;background-color:#f27474;display:block;top:37px;border-radius:2px}.swal-icon--error__line--left{-webkit-transform:rotate(45deg);transform:rotate(45deg);left:17px}.swal-icon--error__line--right{-webkit-transform:rotate(-45deg);transform:rotate(-45deg);right:16px}@-webkit-keyframes animateErrorIcon{0%{-webkit-transform:rotateX(100deg);transform:rotateX(100deg);opacity:0}to{-webkit-transform:rotateX(0deg);transform:rotateX(0deg);opacity:1}}@keyframes animateErrorIcon{0%{-webkit-transform:rotateX(100deg);transform:rotateX(100deg);opacity:0}to{-webkit-transform:rotateX(0deg);transform:rotateX(0deg);opacity:1}}@-webkit-keyframes animateXMark{0%{-webkit-transform:scale(.4);transform:scale(.4);margin-top:26px;opacity:0}50%{-webkit-transform:scale(.4);transform:scale(.4);margin-top:26px;opacity:0}80%{-webkit-transform:scale(1.15);transform:scale(1.15);margin-top:-6px}to{-webkit-transform:scale(1);transform:scale(1);margin-top:0;opacity:1}}@keyframes animateXMark{0%{-webkit-transform:scale(.4);transform:scale(.4);margin-top:26px;opacity:0}50%{-webkit-transform:scale(.4);transform:scale(.4);margin-top:26px;opacity:0}80%{-webkit-transform:scale(1.15);transform:scale(1.15);margin-top:-6px}to{-webkit-transform:scale(1);transform:scale(1);margin-top:0;opacity:1}}.swal-icon--warning{border-color:#f8bb86;-webkit-animation:pulseWarning .75s infinite alternate;animation:pulseWarning .75s infinite alternate}.swal-icon--warning__body{width:5px;height:47px;top:10px;border-radius:2px;margin-left:-2px}.swal-icon--warning__body,.swal-icon--warning__dot{position:absolute;left:50%;background-color:#f8bb86}.swal-icon--warning__dot{width:7px;height:7px;border-radius:50%;margin-left:-4px;bottom:-11px}@-webkit-keyframes pulseWarning{0%{border-color:#f8d486}to{border-color:#f8bb86}}@keyframes pulseWarning{0%{border-color:#f8d486}to{border-color:#f8bb86}}.swal-icon--success{border-color:#a5dc86}.swal-icon--success:after,.swal-icon--success:before{content:"";border-radius:50%;position:absolute;width:60px;height:120px;background:#fff;-webkit-transform:rotate(45deg);transform:rotate(45deg)}.swal-icon--success:before{border-radius:120px 0 0 120px;top:-7px;left:-33px;-webkit-transform:rotate(-45deg);transform:rotate(-45deg);-webkit-transform-origin:60px 60px;transform-origin:60px 60px}.swal-icon--success:after{border-radius:0 120px 120px 0;top:-11px;left:30px;-webkit-transform:rotate(-45deg);transform:rotate(-45deg);-webkit-transform-origin:0 60px;transform-origin:0 60px;-webkit-animation:rotatePlaceholder 4.25s ease-in;animation:rotatePlaceholder 4.25s ease-in}.swal-icon--success__ring{width:80px;height:80px;border:4px solid hsla(98,55%,69%,.2);border-radius:50%;box-sizing:content-box;position:absolute;left:-4px;top:-4px;z-index:2}.swal-icon--success__hide-corners{width:5px;height:90px;background-color:#fff;padding:1px;position:absolute;left:28px;top:8px;z-index:1;-webkit-transform:rotate(-45deg);transform:rotate(-45deg)}.swal-icon--success__line{height:5px;background-color:#a5dc86;display:block;border-radius:2px;position:absolute;z-index:2}.swal-icon--success__line--tip{width:25px;left:14px;top:46px;-webkit-transform:rotate(45deg);transform:rotate(45deg);-webkit-animation:animateSuccessTip .75s;animation:animateSuccessTip .75s}.swal-icon--success__line--long{width:47px;right:8px;top:38px;-webkit-transform:rotate(-45deg);transform:rotate(-45deg);-webkit-animation:animateSuccessLong .75s;animation:animateSuccessLong .75s}@-webkit-keyframes rotatePlaceholder{0%{-webkit-transform:rotate(-45deg);transform:rotate(-45deg)}5%{-webkit-transform:rotate(-45deg);transform:rotate(-45deg)}12%{-webkit-transform:rotate(-405deg);transform:rotate(-405deg)}to{-webkit-transform:rotate(-405deg);transform:rotate(-405deg)}}@keyframes rotatePlaceholder{0%{-webkit-transform:rotate(-45deg);transform:rotate(-45deg)}5%{-webkit-transform:rotate(-45deg);transform:rotate(-45deg)}12%{-webkit-transform:rotate(-405deg);transform:rotate(-405deg)}to{-webkit-transform:rotate(-405deg);transform:rotate(-405deg)}}@-webkit-keyframes animateSuccessTip{0%{width:0;left:1px;top:19px}54%{width:0;left:1px;top:19px}70%{width:50px;left:-8px;top:37px}84%{width:17px;left:21px;top:48px}to{width:25px;left:14px;top:45px}}@keyframes animateSuccessTip{0%{width:0;left:1px;top:19px}54%{width:0;left:1px;top:19px}70%{width:50px;left:-8px;top:37px}84%{width:17px;left:21px;top:48px}to{width:25px;left:14px;top:45px}}@-webkit-keyframes animateSuccessLong{0%{width:0;right:46px;top:54px}65%{width:0;right:46px;top:54px}84%{width:55px;right:0;top:35px}to{width:47px;right:8px;top:38px}}@keyframes animateSuccessLong{0%{width:0;right:46px;top:54px}65%{width:0;right:46px;top:54px}84%{width:55px;right:0;top:35px}to{width:47px;right:8px;top:38px}}.swal-icon--info{border-color:#c9dae1}.swal-icon--info:before{width:5px;height:29px;bottom:17px;border-radius:2px;margin-left:-2px}.swal-icon--info:after,.swal-icon--info:before{content:"";position:absolute;left:50%;background-color:#c9dae1}.swal-icon--info:after{width:7px;height:7px;border-radius:50%;margin-left:-3px;top:19px}.swal-icon{width:80px;height:80px;border-width:4px;border-style:solid;border-radius:50%;padding:0;position:relative;box-sizing:content-box;margin:20px auto}.swal-icon:first-child{margin-top:32px}.swal-icon--custom{width:auto;height:auto;max-width:100%;border:none;border-radius:0}.swal-icon img{max-width:100%;max-height:100%}.swal-title{color:rgba(0,0,0,.65);font-weight:600;text-transform:none;position:relative;display:block;padding:13px 16px;font-size:27px;line-height:normal;text-align:center;margin-bottom:0}.swal-title:first-child{margin-top:26px}.swal-title:not(:first-child){padding-bottom:0}.swal-title:not(:last-child){margin-bottom:13px}.swal-text{font-size:16px;position:relative;float:none;line-height:normal;vertical-align:top;text-align:left;display:inline-block;margin:0;padding:0 10px;font-weight:400;color:rgba(0,0,0,.64);max-width:calc(100% - 20px);overflow-wrap:break-word;box-sizing:border-box}.swal-text:first-child{margin-top:45px}.swal-text:last-child{margin-bottom:45px}.swal-footer{text-align:right;padding-top:13px;margin-top:13px;padding:13px 16px;border-radius:inherit;border-top-left-radius:0;border-top-right-radius:0}.swal-button-container{margin:5px;display:inline-block;position:relative}.swal-button{background-color:#7cd1f9;color:#fff;border:none;box-shadow:none;border-radius:5px;font-weight:600;font-size:14px;padding:10px 24px;margin:0;cursor:pointer}.swal-button:not([disabled]):hover{background-color:#78cbf2}.swal-button:active{background-color:#70bce0}.swal-button:focus{outline:none;box-shadow:0 0 0 1px #fff,0 0 0 3px rgba(43,114,165,.29)}.swal-button[disabled]{opacity:.5;cursor:default}.swal-button::-moz-focus-inner{border:0}.swal-button--cancel{color:#555;background-color:#efefef}.swal-button--cancel:not([disabled]):hover{background-color:#e8e8e8}.swal-button--cancel:active{background-color:#d7d7d7}.swal-button--cancel:focus{box-shadow:0 0 0 1px #fff,0 0 0 3px rgba(116,136,150,.29)}.swal-button--danger{background-color:#e64942}.swal-button--danger:not([disabled]):hover{background-color:#df4740}.swal-button--danger:active{background-color:#cf423b}.swal-button--danger:focus{box-shadow:0 0 0 1px #fff,0 0 0 3px rgba(165,43,43,.29)}.swal-content{padding:0 20px;margin-top:20px;font-size:medium}.swal-content:last-child{margin-bottom:20px}.swal-content__input,.swal-content__textarea{-webkit-appearance:none;background-color:#fff;border:none;font-size:14px;display:block;box-sizing:border-box;width:100%;border:1px solid rgba(0,0,0,.14);padding:10px 13px;border-radius:2px;transition:border-color .2s}.swal-content__input:focus,.swal-content__textarea:focus{outline:none;border-color:#6db8ff}.swal-content__textarea{resize:vertical}.swal-button--loading{color:transparent}.swal-button--loading~.swal-button__loader{opacity:1}.swal-button__loader{position:absolute;height:auto;width:43px;z-index:2;left:50%;top:50%;-webkit-transform:translateX(-50%) translateY(-50%);transform:translateX(-50%) translateY(-50%);text-align:center;pointer-events:none;opacity:0}.swal-button__loader div{display:inline-block;float:none;vertical-align:baseline;width:9px;height:9px;padding:0;border:none;margin:2px;opacity:.4;border-radius:7px;background-color:hsla(0,0%,100%,.9);transition:background .2s;-webkit-animation:swal-loading-anim 1s infinite;animation:swal-loading-anim 1s infinite}.swal-button__loader div:nth-child(3n+2){-webkit-animation-delay:.15s;animation-delay:.15s}.swal-button__loader div:nth-child(3n+3){-webkit-animation-delay:.3s;animation-delay:.3s}@-webkit-keyframes swal-loading-anim{0%{opacity:.4}20%{opacity:.4}50%{opacity:1}to{opacity:.4}}@keyframes swal-loading-anim{0%{opacity:.4}20%{opacity:.4}50%{opacity:1}to{opacity:.4}}.swal-overlay{position:fixed;top:0;bottom:0;left:0;right:0;text-align:center;font-size:0;overflow-y:auto;background-color:rgba(0,0,0,.4);z-index:10000;pointer-events:none;opacity:0;transition:opacity .3s}.swal-overlay:before{content:" ";display:inline-block;vertical-align:middle;height:100%}.swal-overlay--show-modal{opacity:1;pointer-events:auto}.swal-overlay--show-modal .swal-modal{opacity:1;pointer-events:auto;box-sizing:border-box;-webkit-animation:showSweetAlert .3s;animation:showSweetAlert .3s;will-change:transform}.swal-modal{width:478px;opacity:0;pointer-events:none;background-color:#fff;text-align:center;border-radius:5px;position:static;margin:20px auto;display:inline-block;vertical-align:middle;-webkit-transform:scale(1);transform:scale(1);-webkit-transform-origin:50% 50%;transform-origin:50% 50%;z-index:10001;transition:opacity .2s,-webkit-transform .3s;transition:transform .3s,opacity .2s;transition:transform .3s,opacity .2s,-webkit-transform .3s}@media (max-width:500px){.swal-modal{width:calc(100% - 20px)}}@-webkit-keyframes showSweetAlert{0%{-webkit-transform:scale(1);transform:scale(1)}1%{-webkit-transform:scale(.5);transform:scale(.5)}45%{-webkit-transform:scale(1.05);transform:scale(1.05)}80%{-webkit-transform:scale(.95);transform:scale(.95)}to{-webkit-transform:scale(1);transform:scale(1)}}@keyframes showSweetAlert{0%{-webkit-transform:scale(1);transform:scale(1)}1%{-webkit-transform:scale(.5);transform:scale(.5)}45%{-webkit-transform:scale(1.05);transform:scale(1.05)}80%{-webkit-transform:scale(.95);transform:scale(.95)}to{-webkit-transform:scale(1);transform:scale(1)}}',""])},function(t,e){function n(t,e){var n=t[1]||"",r=t[3];if(!r)return n;if(e&&"function"==typeof btoa){var i=o(r);return[n].concat(r.sources.map(function(t){return"/*# sourceURL="+r.sourceRoot+t+" */"})).concat([i]).join("\n")}return[n].join("\n")}function o(t){return"/*# sourceMappingURL=data:application/json;charset=utf-8;base64,"+btoa(unescape(encodeURIComponent(JSON.stringify(t))))+" */"}t.exports=function(t){var e=[];return e.toString=function(){return this.map(function(e){var o=n(e,t);return e[2]?"@media "+e[2]+"{"+o+"}":o}).join("")},e.i=function(t,n){"string"==typeof t&&(t=[[null,t,""]]);for(var o={},r=0;r<this.length;r++){var i=this[r][0];"number"==typeof i&&(o[i]=!0)}for(r=0;r<t.length;r++){var a=t[r];"number"==typeof a[0]&&o[a[0]]||(n&&!a[2]?a[2]=n:n&&(a[2]="("+a[2]+") and ("+n+")"),e.push(a))}},e}},function(t,e,n){function o(t,e){for(var n=0;n<t.length;n++){var o=t[n],r=m[o.id];if(r){r.refs++;for(var i=0;i<r.parts.length;i++)r.parts[i](o.parts[i]);for(;i<o.parts.length;i++)r.parts.push(u(o.parts[i],e))}else{for(var a=[],i=0;i<o.parts.length;i++)a.push(u(o.parts[i],e));m[o.id]={id:o.id,refs:1,parts:a}}}}function r(t,e){for(var n=[],o={},r=0;r<t.length;r++){var i=t[r],a=e.base?i[0]+e.base:i[0],s=i[1],c=i[2],l=i[3],u={css:s,media:c,sourceMap:l};o[a]?o[a].parts.push(u):n.push(o[a]={id:a,parts:[u]})}return n}function i(t,e){var n=v(t.insertInto);if(!n)throw new Error("Couldn't find a style target. This probably means that the value for the 'insertInto' parameter is invalid.");var o=w[w.length-1];if("top"===t.insertAt)o?o.nextSibling?n.insertBefore(e,o.nextSibling):n.appendChild(e):n.insertBefore(e,n.firstChild),w.push(e);else{if("bottom"!==t.insertAt)throw new Error("Invalid value for parameter 'insertAt'. Must be 'top' or 'bottom'.");n.appendChild(e)}}function a(t){if(null===t.parentNode)return!1;t.parentNode.removeChild(t);var e=w.indexOf(t);e>=0&&w.splice(e,1)}function s(t){var e=document.createElement("style");return t.attrs.type="text/css",l(e,t.attrs),i(t,e),e}function c(t){var e=document.createElement("link");return t.attrs.type="text/css",t.attrs.rel="stylesheet",l(e,t.attrs),i(t,e),e}function l(t,e){Object.keys(e).forEach(function(n){t.setAttribute(n,e[n])})}function u(t,e){var n,o,r,i;if(e.transform&&t.css){if(!(i=e.transform(t.css)))return function(){};t.css=i}if(e.singleton){var l=h++;n=g||(g=s(e)),o=f.bind(null,n,l,!1),r=f.bind(null,n,l,!0)}else t.sourceMap&&"function"==typeof URL&&"function"==typeof URL.createObjectURL&&"function"==typeof URL.revokeObjectURL&&"function"==typeof Blob&&"function"==typeof btoa?(n=c(e),o=p.bind(null,n,e),r=function(){a(n),n.href&&URL.revokeObjectURL(n.href)}):(n=s(e),o=d.bind(null,n),r=function(){a(n)});return o(t),function(e){if(e){if(e.css===t.css&&e.media===t.media&&e.sourceMap===t.sourceMap)return;o(t=e)}else r()}}function f(t,e,n,o){var r=n?"":o.css;if(t.styleSheet)t.styleSheet.cssText=x(e,r);else{var i=document.createTextNode(r),a=t.childNodes;a[e]&&t.removeChild(a[e]),a.length?t.insertBefore(i,a[e]):t.appendChild(i)}}function d(t,e){var n=e.css,o=e.media;if(o&&t.setAttribute("media",o),t.styleSheet)t.styleSheet.cssText=n;else{for(;t.firstChild;)t.removeChild(t.firstChild);t.appendChild(document.createTextNode(n))}}function p(t,e,n){var o=n.css,r=n.sourceMap,i=void 0===e.convertToAbsoluteUrls&&r;(e.convertToAbsoluteUrls||i)&&(o=y(o)),r&&(o+="\n/*# sourceMappingURL=data:application/json;base64,"+btoa(unescape(encodeURIComponent(JSON.stringify(r))))+" */");var a=new Blob([o],{type:"text/css"}),s=t.href;t.href=URL.createObjectURL(a),s&&URL.revokeObjectURL(s)}var m={},b=function(t){var e;return function(){return void 0===e&&(e=t.apply(this,arguments)),e}}(function(){return window&&document&&document.all&&!window.atob}),v=function(t){var e={};return function(n){return void 0===e[n]&&(e[n]=t.call(this,n)),e[n]}}(function(t){return document.querySelector(t)}),g=null,h=0,w=[],y=n(15);t.exports=function(t,e){if("undefined"!=typeof DEBUG&&DEBUG&&"object"!=typeof document)throw new Error("The style-loader cannot be used in a non-browser environment");e=e||{},e.attrs="object"==typeof e.attrs?e.attrs:{},e.singleton||(e.singleton=b()),e.insertInto||(e.insertInto="head"),e.insertAt||(e.insertAt="bottom");var n=r(t,e);return o(n,e),function(t){for(var i=[],a=0;a<n.length;a++){var s=n[a],c=m[s.id];c.refs--,i.push(c)}if(t){o(r(t,e),e)}for(var a=0;a<i.length;a++){var c=i[a];if(0===c.refs){for(var l=0;l<c.parts.length;l++)c.parts[l]();delete m[c.id]}}}};var x=function(){var t=[];return function(e,n){return t[e]=n,t.filter(Boolean).join("\n")}}()},function(t,e){t.exports=function(t){var e="undefined"!=typeof window&&window.location;if(!e)throw new Error("fixUrls requires window.location");if(!t||"string"!=typeof t)return t;var n=e.protocol+"//"+e.host,o=n+e.pathname.replace(/\/[^\/]*$/,"/");return t.replace(/url\s*\(((?:[^)(]|\((?:[^)(]+|\([^)(]*\))*\))*)\)/gi,function(t,e){var r=e.trim().replace(/^"(.*)"$/,function(t,e){return e}).replace(/^'(.*)'$/,function(t,e){return e});if(/^(#|data:|http:\/\/|https:\/\/|file:\/\/\/)/i.test(r))return t;var i;return i=0===r.indexOf("//")?r:0===r.indexOf("/")?n+r:o+r.replace(/^\.\//,""),"url("+JSON.stringify(i)+")"})}},function(t,e,n){var o=n(17);"undefined"==typeof window||window.Promise||(window.Promise=o),n(21),String.prototype.includes||(String.prototype.includes=function(t,e){"use strict";return"number"!=typeof e&&(e=0),!(e+t.length>this.length)&&-1!==this.indexOf(t,e)}),Array.prototype.includes||Object.defineProperty(Array.prototype,"includes",{value:function(t,e){if(null==this)throw new TypeError('"this" is null or not defined');var n=Object(this),o=n.length>>>0;if(0===o)return!1;for(var r=0|e,i=Math.max(r>=0?r:o-Math.abs(r),0);i<o;){if(function(t,e){return t===e||"number"==typeof t&&"number"==typeof e&&isNaN(t)&&isNaN(e)}(n[i],t))return!0;i++}return!1}}),"undefined"!=typeof window&&function(t){t.forEach(function(t){t.hasOwnProperty("remove")||Object.defineProperty(t,"remove",{configurable:!0,enumerable:!0,writable:!0,value:function(){this.parentNode.removeChild(this)}})})}([Element.prototype,CharacterData.prototype,DocumentType.prototype])},function(t,e,n){(function(e){!function(n){function o(){}function r(t,e){return function(){t.apply(e,arguments)}}function i(t){if("object"!=typeof this)throw new TypeError("Promises must be constructed via new");if("function"!=typeof t)throw new TypeError("not a function");this._state=0,this._handled=!1,this._value=void 0,this._deferreds=[],f(t,this)}function a(t,e){for(;3===t._state;)t=t._value;if(0===t._state)return void t._deferreds.push(e);t._handled=!0,i._immediateFn(function(){var n=1===t._state?e.onFulfilled:e.onRejected;if(null===n)return void(1===t._state?s:c)(e.promise,t._value);var o;try{o=n(t._value)}catch(t){return void c(e.promise,t)}s(e.promise,o)})}function s(t,e){try{if(e===t)throw new TypeError("A promise cannot be resolved with itself.");if(e&&("object"==typeof e||"function"==typeof e)){var n=e.then;if(e instanceof i)return t._state=3,t._value=e,void l(t);if("function"==typeof n)return void f(r(n,e),t)}t._state=1,t._value=e,l(t)}catch(e){c(t,e)}}function c(t,e){t._state=2,t._value=e,l(t)}function l(t){2===t._state&&0===t._deferreds.length&&i._immediateFn(function(){t._handled||i._unhandledRejectionFn(t._value)});for(var e=0,n=t._deferreds.length;e<n;e++)a(t,t._deferreds[e]);t._deferreds=null}function u(t,e,n){this.onFulfilled="function"==typeof t?t:null,this.onRejected="function"==typeof e?e:null,this.promise=n}function f(t,e){var n=!1;try{t(function(t){n||(n=!0,s(e,t))},function(t){n||(n=!0,c(e,t))})}catch(t){if(n)return;n=!0,c(e,t)}}var d=setTimeout;i.prototype.catch=function(t){return this.then(null,t)},i.prototype.then=function(t,e){var n=new this.constructor(o);return a(this,new u(t,e,n)),n},i.all=function(t){var e=Array.prototype.slice.call(t);return new i(function(t,n){function o(i,a){try{if(a&&("object"==typeof a||"function"==typeof a)){var s=a.then;if("function"==typeof s)return void s.call(a,function(t){o(i,t)},n)}e[i]=a,0==--r&&t(e)}catch(t){n(t)}}if(0===e.length)return t([]);for(var r=e.length,i=0;i<e.length;i++)o(i,e[i])})},i.resolve=function(t){return t&&"object"==typeof t&&t.constructor===i?t:new i(function(e){e(t)})},i.reject=function(t){return new i(function(e,n){n(t)})},i.race=function(t){return new i(function(e,n){for(var o=0,r=t.length;o<r;o++)t[o].then(e,n)})},i._immediateFn="function"==typeof e&&function(t){e(t)}||function(t){d(t,0)},i._unhandledRejectionFn=function(t){"undefined"!=typeof console&&console&&console.warn("Possible Unhandled Promise Rejection:",t)},i._setImmediateFn=function(t){i._immediateFn=t},i._setUnhandledRejectionFn=function(t){i._unhandledRejectionFn=t},void 0!==t&&t.exports?t.exports=i:n.Promise||(n.Promise=i)}(this)}).call(e,n(18).setImmediate)},function(t,e,n){function o(t,e){this._id=t,this._clearFn=e}var r=Function.prototype.apply;e.setTimeout=function(){return new o(r.call(setTimeout,window,arguments),clearTimeout)},e.setInterval=function(){return new o(r.call(setInterval,window,arguments),clearInterval)},e.clearTimeout=e.clearInterval=function(t){t&&t.close()},o.prototype.unref=o.prototype.ref=function(){},o.prototype.close=function(){this._clearFn.call(window,this._id)},e.enroll=function(t,e){clearTimeout(t._idleTimeoutId),t._idleTimeout=e},e.unenroll=function(t){clearTimeout(t._idleTimeoutId),t._idleTimeout=-1},e._unrefActive=e.active=function(t){clearTimeout(t._idleTimeoutId);var e=t._idleTimeout;e>=0&&(t._idleTimeoutId=setTimeout(function(){t._onTimeout&&t._onTimeout()},e))},n(19),e.setImmediate=setImmediate,e.clearImmediate=clearImmediate},function(t,e,n){(function(t,e){!function(t,n){"use strict";function o(t){"function"!=typeof t&&(t=new Function(""+t));for(var e=new Array(arguments.length-1),n=0;n<e.length;n++)e[n]=arguments[n+1];var o={callback:t,args:e};return l[c]=o,s(c),c++}function r(t){delete l[t]}function i(t){var e=t.callback,o=t.args;switch(o.length){case 0:e();break;case 1:e(o[0]);break;case 2:e(o[0],o[1]);break;case 3:e(o[0],o[1],o[2]);break;default:e.apply(n,o)}}function a(t){if(u)setTimeout(a,0,t);else{var e=l[t];if(e){u=!0;try{i(e)}finally{r(t),u=!1}}}}if(!t.setImmediate){var s,c=1,l={},u=!1,f=t.document,d=Object.getPrototypeOf&&Object.getPrototypeOf(t);d=d&&d.setTimeout?d:t,"[object process]"==={}.toString.call(t.process)?function(){s=function(t){e.nextTick(function(){a(t)})}}():function(){if(t.postMessage&&!t.importScripts){var e=!0,n=t.onmessage;return t.onmessage=function(){e=!1},t.postMessage("","*"),t.onmessage=n,e}}()?function(){var e="setImmediate$"+Math.random()+"$",n=function(n){n.source===t&&"string"==typeof n.data&&0===n.data.indexOf(e)&&a(+n.data.slice(e.length))};t.addEventListener?t.addEventListener("message",n,!1):t.attachEvent("onmessage",n),s=function(n){t.postMessage(e+n,"*")}}():t.MessageChannel?function(){var t=new MessageChannel;t.port1.onmessage=function(t){a(t.data)},s=function(e){t.port2.postMessage(e)}}():f&&"onreadystatechange"in f.createElement("script")?function(){var t=f.documentElement;s=function(e){var n=f.createElement("script");n.onreadystatechange=function(){a(e),n.onreadystatechange=null,t.removeChild(n),n=null},t.appendChild(n)}}():function(){s=function(t){setTimeout(a,0,t)}}(),d.setImmediate=o,d.clearImmediate=r}}("undefined"==typeof self?void 0===t?this:t:self)}).call(e,n(7),n(20))},function(t,e){function n(){throw new Error("setTimeout has not been defined")}function o(){throw new Error("clearTimeout has not been defined")}function r(t){if(u===setTimeout)return setTimeout(t,0);if((u===n||!u)&&setTimeout)return u=setTimeout,setTimeout(t,0);try{return u(t,0)}catch(e){try{return u.call(null,t,0)}catch(e){return u.call(this,t,0)}}}function i(t){if(f===clearTimeout)return clearTimeout(t);if((f===o||!f)&&clearTimeout)return f=clearTimeout,clearTimeout(t);try{return f(t)}catch(e){try{return f.call(null,t)}catch(e){return f.call(this,t)}}}function a(){b&&p&&(b=!1,p.length?m=p.concat(m):v=-1,m.length&&s())}function s(){if(!b){var t=r(a);b=!0;for(var e=m.length;e;){for(p=m,m=[];++v<e;)p&&p[v].run();v=-1,e=m.length}p=null,b=!1,i(t)}}function c(t,e){this.fun=t,this.array=e}function l(){}var u,f,d=t.exports={};!function(){try{u="function"==typeof setTimeout?setTimeout:n}catch(t){u=n}try{f="function"==typeof clearTimeout?clearTimeout:o}catch(t){f=o}}();var p,m=[],b=!1,v=-1;d.nextTick=function(t){var e=new Array(arguments.length-1);if(arguments.length>1)for(var n=1;n<arguments.length;n++)e[n-1]=arguments[n];m.push(new c(t,e)),1!==m.length||b||r(s)},c.prototype.run=function(){this.fun.apply(null,this.array)},d.title="browser",d.browser=!0,d.env={},d.argv=[],d.version="",d.versions={},d.on=l,d.addListener=l,d.once=l,d.off=l,d.removeListener=l,d.removeAllListeners=l,d.emit=l,d.prependListener=l,d.prependOnceListener=l,d.listeners=function(t){return[]},d.binding=function(t){throw new Error("process.binding is not supported")},d.cwd=function(){return"/"},d.chdir=function(t){throw new Error("process.chdir is not supported")},d.umask=function(){return 0}},function(t,e,n){"use strict";n(22).polyfill()},function(t,e,n){"use strict";function o(t,e){if(void 0===t||null===t)throw new TypeError("Cannot convert first argument to object");for(var n=Object(t),o=1;o<arguments.length;o++){var r=arguments[o];if(void 0!==r&&null!==r)for(var i=Object.keys(Object(r)),a=0,s=i.length;a<s;a++){var c=i[a],l=Object.getOwnPropertyDescriptor(r,c);void 0!==l&&l.enumerable&&(n[c]=r[c])}}return n}function r(){Object.assign||Object.defineProperty(Object,"assign",{enumerable:!1,configurable:!0,writable:!0,value:o})}t.exports={assign:o,polyfill:r}},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(24),r=n(6),i=n(5),a=n(36),s=function(){for(var t=[],e=0;e<arguments.length;e++)t[e]=arguments[e];if("undefined"!=typeof window){var n=a.getOpts.apply(void 0,t);return new Promise(function(t,e){i.default.promise={resolve:t,reject:e},o.default(n),setTimeout(function(){r.openModal()})})}};s.close=r.onAction,s.getState=r.getState,s.setActionValue=i.setActionValue,s.stopLoading=r.stopLoading,s.setDefaults=a.setDefaults,e.default=s},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),r=n(0),i=r.default.MODAL,a=n(4),s=n(34),c=n(35),l=n(1);e.init=function(t){o.getNode(i)||(document.body||l.throwErr("You can only use SweetAlert AFTER the DOM has loaded!"),s.default(),a.default()),a.initModalContent(t),c.default(t)},e.default=e.init},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(0),r=o.default.MODAL;e.modalMarkup='\n  <div class="'+r+'" role="dialog" aria-modal="true"></div>',e.default=e.modalMarkup},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(0),r=o.default.OVERLAY,i='<div \n    class="'+r+'"\n    tabIndex="-1">\n  </div>';e.default=i},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(0),r=o.default.ICON;e.errorIconMarkup=function(){var t=r+"--error",e=t+"__line";return'\n    <div class="'+t+'__x-mark">\n      <span class="'+e+" "+e+'--left"></span>\n      <span class="'+e+" "+e+'--right"></span>\n    </div>\n  '},e.warningIconMarkup=function(){var t=r+"--warning";return'\n    <span class="'+t+'__body">\n      <span class="'+t+'__dot"></span>\n    </span>\n  '},e.successIconMarkup=function(){var t=r+"--success";return'\n    <span class="'+t+"__line "+t+'__line--long"></span>\n    <span class="'+t+"__line "+t+'__line--tip"></span>\n\n    <div class="'+t+'__ring"></div>\n    <div class="'+t+'__hide-corners"></div>\n  '}},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(0),r=o.default.CONTENT;e.contentMarkup='\n  <div class="'+r+'">\n\n  </div>\n'},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(0),r=o.default.BUTTON_CONTAINER,i=o.default.BUTTON,a=o.default.BUTTON_LOADER;e.buttonMarkup='\n  <div class="'+r+'">\n\n    <button\n      class="'+i+'"\n    ></button>\n\n    <div class="'+a+'">\n      <div></div>\n      <div></div>\n      <div></div>\n    </div>\n\n  </div>\n'},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(4),r=n(2),i=n(0),a=i.default.ICON,s=i.default.ICON_CUSTOM,c=["error","warning","success","info"],l={error:r.errorIconMarkup(),warning:r.warningIconMarkup(),success:r.successIconMarkup()},u=function(t,e){var n=a+"--"+t;e.classList.add(n);var o=l[t];o&&(e.innerHTML=o)},f=function(t,e){e.classList.add(s);var n=document.createElement("img");n.src=t,e.appendChild(n)},d=function(t){if(t){var e=o.injectElIntoModal(r.iconMarkup);c.includes(t)?u(t,e):f(t,e)}};e.default=d},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(2),r=n(4),i=function(t){navigator.userAgent.includes("AppleWebKit")&&(t.style.display="none",t.offsetHeight,t.style.display="")};e.initTitle=function(t){if(t){var e=r.injectElIntoModal(o.titleMarkup);e.textContent=t,i(e)}},e.initText=function(t){if(t){var e=document.createDocumentFragment();t.split("\n").forEach(function(t,n,o){e.appendChild(document.createTextNode(t)),n<o.length-1&&e.appendChild(document.createElement("br"))});var n=r.injectElIntoModal(o.textMarkup);n.appendChild(e),i(n)}}},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),r=n(4),i=n(0),a=i.default.BUTTON,s=i.default.DANGER_BUTTON,c=n(3),l=n(2),u=n(6),f=n(5),d=function(t,e,n){var r=e.text,i=e.value,d=e.className,p=e.closeModal,m=o.stringToNode(l.buttonMarkup),b=m.querySelector("."+a),v=a+"--"+t;if(b.classList.add(v),d){(Array.isArray(d)?d:d.split(" ")).filter(function(t){return t.length>0}).forEach(function(t){b.classList.add(t)})}n&&t===c.CONFIRM_KEY&&b.classList.add(s),b.textContent=r;var g={};return g[t]=i,f.setActionValue(g),f.setActionOptionsFor(t,{closeModal:p}),b.addEventListener("click",function(){return u.onAction(t)}),m},p=function(t,e){var n=r.injectElIntoModal(l.footerMarkup);for(var o in t){var i=t[o],a=d(o,i,e);i.visible&&n.appendChild(a)}0===n.children.length&&n.remove()};e.default=p},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(3),r=n(4),i=n(2),a=n(5),s=n(6),c=n(0),l=c.default.CONTENT,u=function(t){t.addEventListener("input",function(t){var e=t.target,n=e.value;a.setActionValue(n)}),t.addEventListener("keyup",function(t){if("Enter"===t.key)return s.onAction(o.CONFIRM_KEY)}),setTimeout(function(){t.focus(),a.setActionValue("")},0)},f=function(t,e,n){var o=document.createElement(e),r=l+"__"+e;o.classList.add(r);for(var i in n){var a=n[i];o[i]=a}"input"===e&&u(o),t.appendChild(o)},d=function(t){if(t){var e=r.injectElIntoModal(i.contentMarkup),n=t.element,o=t.attributes;"string"==typeof n?f(e,n,o):e.appendChild(n)}};e.default=d},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),r=n(2),i=function(){var t=o.stringToNode(r.overlayMarkup);document.body.appendChild(t)};e.default=i},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(5),r=n(6),i=n(1),a=n(3),s=n(0),c=s.default.MODAL,l=s.default.BUTTON,u=s.default.OVERLAY,f=function(t){t.preventDefault(),v()},d=function(t){t.preventDefault(),g()},p=function(t){if(o.default.isOpen)switch(t.key){case"Escape":return r.onAction(a.CANCEL_KEY)}},m=function(t){if(o.default.isOpen)switch(t.key){case"Tab":return f(t)}},b=function(t){if(o.default.isOpen)return"Tab"===t.key&&t.shiftKey?d(t):void 0},v=function(){var t=i.getNode(l);t&&(t.tabIndex=0,t.focus())},g=function(){var t=i.getNode(c),e=t.querySelectorAll("."+l),n=e.length-1,o=e[n];o&&o.focus()},h=function(t){t[t.length-1].addEventListener("keydown",m)},w=function(t){t[0].addEventListener("keydown",b)},y=function(){var t=i.getNode(c),e=t.querySelectorAll("."+l);e.length&&(h(e),w(e))},x=function(t){if(i.getNode(u)===t.target)return r.onAction(a.CANCEL_KEY)},_=function(t){var e=i.getNode(u);e.removeEventListener("click",x),t&&e.addEventListener("click",x)},k=function(t){o.default.timer&&clearTimeout(o.default.timer),t&&(o.default.timer=window.setTimeout(function(){return r.onAction(a.CANCEL_KEY)},t))},O=function(t){t.closeOnEsc?document.addEventListener("keyup",p):document.removeEventListener("keyup",p),t.dangerMode?v():g(),y(),_(t.closeOnClickOutside),k(t.timer)};e.default=O},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),r=n(3),i=n(37),a=n(38),s={title:null,text:null,icon:null,buttons:r.defaultButtonList,content:null,className:null,closeOnClickOutside:!0,closeOnEsc:!0,dangerMode:!1,timer:null},c=Object.assign({},s);e.setDefaults=function(t){c=Object.assign({},s,t)};var l=function(t){var e=t&&t.button,n=t&&t.buttons;return void 0!==e&&void 0!==n&&o.throwErr("Cannot set both 'button' and 'buttons' options!"),void 0!==e?{confirm:e}:n},u=function(t){return o.ordinalSuffixOf(t+1)},f=function(t,e){o.throwErr(u(e)+" argument ('"+t+"') is invalid")},d=function(t,e){var n=t+1,r=e[n];o.isPlainObject(r)||void 0===r||o.throwErr("Expected "+u(n)+" argument ('"+r+"') to be a plain object")},p=function(t,e){var n=t+1,r=e[n];void 0!==r&&o.throwErr("Unexpected "+u(n)+" argument ("+r+")")},m=function(t,e,n,r){var i=typeof e,a="string"===i,s=e instanceof Element;if(a){if(0===n)return{text:e};if(1===n)return{text:e,title:r[0]};if(2===n)return d(n,r),{icon:e};f(e,n)}else{if(s&&0===n)return d(n,r),{content:e};if(o.isPlainObject(e))return p(n,r),e;f(e,n)}};e.getOpts=function(){for(var t=[],e=0;e<arguments.length;e++)t[e]=arguments[e];var n={};t.forEach(function(e,o){var r=m(0,e,o,t);Object.assign(n,r)});var o=l(n);n.buttons=r.getButtonListOpts(o),delete n.button,n.content=i.getContentOpts(n.content);var u=Object.assign({},s,c,n);return Object.keys(u).forEach(function(t){a.DEPRECATED_OPTS[t]&&a.logDeprecation(t)}),u}},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0});var o=n(1),r={element:"input",attributes:{placeholder:""}};e.getContentOpts=function(t){var e={};return o.isPlainObject(t)?Object.assign(e,t):t instanceof Element?{element:t}:"input"===t?r:null}},function(t,e,n){"use strict";Object.defineProperty(e,"__esModule",{value:!0}),e.logDeprecation=function(t){var n=e.DEPRECATED_OPTS[t],o=n.onlyRename,r=n.replacement,i=n.subOption,a=n.link,s=o?"renamed":"deprecated",c='SweetAlert warning: "'+t+'" option has been '+s+".";if(r){c+=" Please use"+(i?' "'+i+'" in ':" ")+'"'+r+'" instead.'}var l="https://sweetalert.js.org";c+=a?" More details: "+l+a:" More details: "+l+"/guides/#upgrading-from-1x",console.warn(c)},e.DEPRECATED_OPTS={type:{replacement:"icon",link:"/docs/#icon"},imageUrl:{replacement:"icon",link:"/docs/#icon"},customClass:{replacement:"className",onlyRename:!0,link:"/docs/#classname"},imageSize:{},showCancelButton:{replacement:"buttons",link:"/docs/#buttons"},showConfirmButton:{replacement:"button",link:"/docs/#button"},confirmButtonText:{replacement:"button",link:"/docs/#button"},confirmButtonColor:{},cancelButtonText:{replacement:"buttons",link:"/docs/#buttons"},closeOnConfirm:{replacement:"button",subOption:"closeModal",link:"/docs/#button"},closeOnCancel:{replacement:"buttons",subOption:"closeModal",link:"/docs/#buttons"},showLoaderOnConfirm:{replacement:"buttons"},animation:{},inputType:{replacement:"content",link:"/docs/#content"},inputValue:{replacement:"content",link:"/docs/#content"},inputPlaceholder:{replacement:"content",link:"/docs/#content"},html:{replacement:"content",link:"/docs/#content"},allowEscapeKey:{replacement:"closeOnEsc",onlyRename:!0,link:"/docs/#closeonesc"},allowClickOutside:{replacement:"closeOnClickOutside",onlyRename:!0,link:"/docs/#closeonclickoutside"}}}])});
// Place all the behaviors and hooks related to the matching controller here.



// Sortable

//--- Nestable

// --- Sweet Alert

;
