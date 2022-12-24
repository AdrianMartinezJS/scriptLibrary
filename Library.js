/**
 * Ordered Array max to min in order of the property given
 * @param {string} property 
 * @returns 
 * @usage <array>.sort(dynamicSort(<propertyAsString>))
 */
function dynamicSort(property) {
    var sortOrder = 1;
    return function (a,b) {
        var result = (a[property] > b[property]) ? -1 : (a[property] < b[property]) ? 1 : 0;
        return result * sortOrder;
    }
}

/**
 * For this function you need the dynamicSort function as well
 * Ordered array max to min in order of the properties given. Bigger value has the first property
 * @param {array} arguments 
 * @returns The sort parameter
 * @usage <array>.sort(dynamicSortMultiple(<propertiesAsArray>))
 */
function dynamicSortMultiple(arguments) {
    let props = arguments;
    return function (obj1, obj2) {
        let i = 0, result = 0, numberOfProperties = props.length;
        while(result === 0 && i < numberOfProperties) {
            result = dynamicSort(props[i])(obj1, obj2);
            i++;
        }
        return result;
    }
}

/**
 * Sort the given array DESC
 * @param {array} arrayToSort 
 * @param {string} property 
 * @returns The sorted Array. Change a for b in the localeCompare function, do change from DESC to ASC
 */
function sortTheArray(arrayToSort, property) {
    return arrayToSort.sort((a, b) => b[property].localeCompare(a[property]));
}

/**
 * You can give dates or integers. Use it to proove if a time or a number is between the other two parameters
 * @param {date} timeToProove 
 * @param {data} fromTime 
 * @param {date} toTime 
 * @returns true if timeToProove is between the other times, or false if not
 */
function betweenSpecifiedTime(timeToProove, fromTime, toTime) {
    let between = false;
    if (timeToProove > fromTime && timeToProove < toTime) between = true
    return between
}