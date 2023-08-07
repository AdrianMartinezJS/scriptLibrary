<script type="text/javascript">

/*
*	Author: Adrian Martinez
*	Date: 14.03.2023
*	This repository is meant to hold all functions that we use in every PU
*	Please take care by editing! It will affect every PU!
*/

function getTextFromArea(page, x, y, w, h) {
	if (page.hasExternalItems()) page = page.resolveExternalItems();

	var txtArea = page.captureText(new Length(x), new Length(y), new Length(w), new Length(h));
	var text = txtArea.getText();

	var wrappedText = text.map(function (element) {
		return element.trim();
	})
	return wrappedText;
}

function _calculateEasterDate(year) {
  var a = year % 19;
  var b = Math.floor(year / 100);
  var c = year % 100;
  var d = Math.floor(b / 4);
  var e = b % 4;
  var f = Math.floor((b + 8) / 25);
  var g = Math.floor((b - f + 1) / 3);
  var h = (19 * a + b - d - g + 15) % 30;
  var i = Math.floor(c / 4);
  var k = c % 4;
  var l = (32 + 2 * e + 2 * i - h - k) % 7;
  var m = Math.floor((a + 11 * h + 22 * l) / 451);
  var n = Math.floor((h + l - 7 * m + 114) / 31);
  var p = (h + l - 7 * m + 114) % 31;
  return new Date(year, n - 1, p + 1);
}

function _calculateHolidays(year) {
  var holidays = {
    Neujahrstag: new Date(year, 0, 1).toLocaleDateString(),
    Heilige_Drei_Könige: new Date(year, 0, 6).toLocaleDateString(),
    Ostermontag: null,
    Staatsfeiertag: new Date(year, 4, 1).toLocaleDateString(),
    Christi_Himmelfahrt: null,
    Pfingstmontag: null,
    Fronleichnam: null,
    Mariä_Himmelfahrt: new Date(year, 7, 15).toLocaleDateString(),
    Nationalfeiertag: new Date(year, 9, 26).toLocaleDateString(),
    Allerheiligen: new Date(year, 10, 1).toLocaleDateString(),
    Mariä_Empfängnis: new Date(year, 11, 8).toLocaleDateString(),
    Christtag: new Date(year, 11, 25).toLocaleDateString(),
    Stefanitag: new Date(year, 11, 26).toLocaleDateString(),
  };
  const easter = _calculateEasterDate(year);

  var easterMonday = new Date(easter.getTime() + 1 * 24 * 60 * 60 * 1000).toLocaleDateString();
  holidays.Ostermontag = easterMonday;

  var himmelfahrt = new Date(easter.getTime() + 39 * 24 * 60 * 60 * 1000).toLocaleDateString();
  holidays.Christi_Himmelfahrt = himmelfahrt;

  var pfingsten = new Date(easter.getTime() + 49 * 24 * 60 * 60 * 1000);
  var pfingstmontag = new Date(pfingsten.getTime() + 1 * 24 * 60 * 60 * 1000).toLocaleDateString();
  holidays.Pfingstmontag = pfingstmontag;

  var fronleichnam = new Date(easter.getTime() + 60 * 24 * 60 * 60 * 1000).toLocaleDateString();
  holidays.Fronleichnam = fronleichnam;

  var holidaysAsArray = [];
  for (var key in holidays) holidaysAsArray.push(holidays[key]);

  return holidaysAsArray;
}

function _getNextValidDate(dateToCheck) {
  var isWeekend = dateToCheck.getDay() == 0 || dateToCheck.getDay() == 6;
  var holidaysFromGivenYear = _calculateHolidays(dateToCheck.getFullYear());
  var isHoliday = holidaysFromGivenYear.indexOf(
    dateToCheck.toLocaleDateString()
  );
  while (isHoliday != -1 || isWeekend) {
    dateToCheck.setDate(dateToCheck.getDate() + 1);
    holidaysFromGivenYear = _calculateHolidays(dateToCheck.getFullYear());
    isHoliday = holidaysFromGivenYear.indexOf(dateToCheck.toLocaleDateString());
    isWeekend = dateToCheck.getDay() == 0 || dateToCheck.getDay() == 6;
  }

  return dateToCheck;
}

function _checkCutOffTime(dateObjectToCheck, cutOffTime) {
  var isInTimeWindow = true;
  var [cutOffHours, cutOffMinutes] = cutOffTime.split(":");
  var cutOffDate = new Date(dateObjectToCheck.getFullYear(), dateObjectToCheck.getMonth(), dateObjectToCheck.getDate(), cutOffHours, cutOffMinutes);
  if (dateObjectToCheck.getTime() >= cutOffDate.getTime()) {
    isInTimeWindow = false;
  }
  return isInTimeWindow;
}

function setSLA(todayAsDate, slaDaysToAdd, cutOffTime) {
  var cutOffTime = cutOffTime || null;
  if (cutOffTime) {
    if (!_checkCutOffTime(todayAsDate, cutOffTime)) {
      todayAsDate.setDate(todayAsDate.getDate() + 1);
    }
  }
  todayAsDate = _getNextValidDate(todayAsDate);
  var wishedDeliveryDate = new Date(todayAsDate);
  while (slaDaysToAdd > 0) {
    wishedDeliveryDate.setDate(wishedDeliveryDate.getDate() + 1);
    wishedDeliveryDate = _getNextValidDate(wishedDeliveryDate);
    slaDaysToAdd--;
  }
  var slaText =
    ("00" + wishedDeliveryDate.getDate()).slice(-2) +
    "." +
    ("00" + (wishedDeliveryDate.getMonth() + 1)).slice(-2) +
    "." +
    wishedDeliveryDate.getFullYear();
  return slaText;
}

//formatiert new Date in YYYYMMDD
const dateFormaterToFullYearMonthDay = function (date) {
  var localeDate = date.toLocaleDateString();
  var dateArr = localeDate.split("/");
  var year = dateArr[2],
	  day = dateArr[1],
	  month = dateArr[0];

  return "" + year + month + day;
}

const getCodeFromDataMatrix = function(page, x, y, w, h) {
	var bc = page.captureDataMatrixBarcode(x, y, w, h);
	var DMbyteArray = bc.getDataBinary();
	var DMstring = "";
	for(var element in DMbyteArray)
	{
		DMstring += String.fromCharCode(DMbyteArray[element]);
	}
	return DMstring;
}

function getNumberOfPagesFromDatei(path, dateiName, dateiTyp){
  var pages = 0;

  var filepath = path + "/" + dateiName + "." + dateiTyp;
  var f = new FileInputDocument(filepath);
  pages = f.getNumberOfPages();
  f.close();		

  return pages;
}

// Example to call the Function
// var heute = new Date("2024-12-24T11:01"); // Heutiges dateToCheck erstellen
// var sla = setSLA(heute, 2, "11:01");
// print(sla);

// <!ENTITY JS_functionRepository		      	SYSTEM "../../../../common/scripts/lib/functionRepository.js">
// <script-repository-item>	&JS_functionRepository;				</script-repository-item>
</script>