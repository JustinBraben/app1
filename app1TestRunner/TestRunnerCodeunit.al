codeunit 50102 TestRunnerCodeunit
{
    SubType = TestRunner;

    trigger OnRun()
    var
        EnabledTestCodeunit: Record "CAL Test Enabled Codeunit";
        Object: Record "Object";
    begin
        if EnabledTestCodeunit.FINDSET then
            repeat
                if Object.GET(ObjectType::Codeunit, '', EnabledTestCodeunit."Test Codeunit ID") then
                    CODEUNIT.RUN(EnabledTestCodeunit."Test Codeunit ID");
                until EnabledTestCodeunit.NEXT = 0

    end;
}

