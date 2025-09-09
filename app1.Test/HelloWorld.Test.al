codeunit 50000 "HelloWorld Test"
{
    Subtype = Test;

    [Test]
    [HandlerFunctions('HelloWorldMessageHandler')]
    procedure TestHelloWorldMessage()
    var
        CustList: TestPage "Customer List";
    begin
        CustList.OpenView();
        CustList.Close();
        if (not MessageDisplayed) then
            ERROR('Message was not displayed!');
    end;

    [MessageHandler]
    procedure HelloWorldMessageHandler(Message: Text[1024])
    begin
        MessageDisplayed := MessageDisplayed or (Message = 'App published: Hello world');
    end;

    // [Test]
    // local procedure TestCustomerCreation()
    // var
    //     Customer: Record Customer;
    //     LibraryUtil: Codeunit "Sales Line";
    // begin
    //     Base Application
    // end;

    var
        MessageDisplayed: Boolean;
}

