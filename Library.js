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
 * Ordered array max to min based on the properties given.
 * @param {array} properties 
 * @returns The sort parameter
 * @usage <array>.sort(dynamicSortMultiple(<propertiesAsArray>))
 */
function dynamicSortMultiple(properties) {
    let props = properties;
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
 * @returns The Array sorted DESC.
 */
function sortArrayBasedOnElementPropertyDESC(arrayToSort, property) {
    return arrayToSort.sort((a, b) => b[property].localeCompare(a[property]));
}

/**
 * Sort the given array ASC
 * @param {array} arrayToSort 
 * @param {string} property 
 * @returns The Array sorted ASC.
 */
function sortArrayBasedOnElementPropertyASC(arrayToSort, property) {
    return arrayToSort.sort((a, b) => a[property].localeCompare(b[property]));
}

/**
 * You can give dates or integers. Use it to proove if a time or a number is between the other two
 * @param {date} valueToProve 
 * @param {data} firstValue 
 * @param {date} secondValue 
 * @returns true if valueToProve is between the other, false otherwise
 */
function checkIfFirstValueIsBetweenSecondAndThirdValue(valueToProve, firstValue, secondValue) {
    let isBetweenOrNot = false;
    if (valueToProve > firstValue && valueToProve < secondValue) isBetweenOrNot = true
    return isBetweenOrNot
}