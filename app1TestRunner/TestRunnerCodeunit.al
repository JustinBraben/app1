codeunit 50102 TestRunnerCodeunit
{
    SubType = TestRunner;

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Reversal-Post");
        // Codeunit.Run(Codeunit::"ERM Sales Quotes");
    end;
}

