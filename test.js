
// Get the handle of applications main window
var window = UIATarget.localTarget().frontMostApp().mainWindow(); 

// Get the handle of view
var view = window.elements()[0];

var textfields = window.textFields();
var passwordfields = window.secureTextFields();
var buttons = window.buttons();
var textviews = window.textViews();
var statictexts = window.staticTexts();
var images = window.images();

var target = UIATarget.localTarget();

// Check number of Text field(s)
if(textfields.length!=0)
{
    UIALogger.logFail("FAIL: Invalid number of Text field(s)");
}
else
{
    UIALogger.logPass("PASS: Correct number of Text field(s)");
}

// Check number of Secure field(s)

if(passwordfields.length!=0)
{
    UIALogger.logFail("FAIL: Invalid number of Secure field(s)");
} 
else 
{
    UIALogger.logPass("PASS: Correct number of Secure field(s)");
}

// Check number of static field(s)
if(statictexts.length!=1)
{
    UIALogger.logFail("FAIL: Invalid number of static field(s)");
} 
else 
{
    UIALogger.logPass("PASS: Correct number of static field(s)");
}
// Check number of buttons(s)
if(buttons.length!=3)
{
    UIALogger.logFail("FAIL: Invalid number of button(s)");
} 
else 
{
    UIALogger.logPass("PASS: Correct number of button(s)");
}

// Check number of images(s)
if(images.length!=2)
{
    UIALogger.logFail("FAIL: Invalid number of image(s)");
} 
else 
{
    UIALogger.logPass("PASS: Correct number of image(s)");
}


UIALogger.logStart("Logging element tree …");
target.logElementTree();
UIALogger.logPass();

//TESTCASE 1 : Successful Log On 
if(buttons["signing"]==null || buttons["signin"].toString() == "[object UIAElementNil]")
{
    UIALogger.logFail("FAIL:Desired UIButton not found.");
}
else
{
    UIALogger.logPass("PASS: Desired UIButton is available");
    buttons["signin"].tap();
	target.delay(1);
}


/*UIALogger.logStart("Logging element tree …");

window.logElementTree();
UIALogger.logPass();

UIATarget.localTarget().frontMostApp().mainWindow().navigationBar().logElementTree();*/
UIATarget.localTarget().frontMostApp().mainWindow().navigationBar().buttons()[1].tap();
target.delay(1);

UIATarget.localTarget().tap({x:50, y:280});
target.delay(1);


UIATarget.localTarget().frontMostApp().mainWindow().navigationBar().buttons()[0].tap();
target.delay(1);

UIATarget.localTarget().dragFromToForDuration({x:160, y:400}, {x:160, y:200}, 1);

window.scrollViews()[0].logElementTree();
target.delay(1);
UIATarget.localTarget().tap({x:200, y:500});

target.delay(1);
UIATarget.localTarget().tap({x:200, y:250});

target.delay(1);
UIATarget.localTarget().tap({x:200, y:530});



/* window.scrollViews()[0].textViews()["about"].tap(); */

