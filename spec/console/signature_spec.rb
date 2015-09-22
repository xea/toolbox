require 'console/signature'

RSpec.describe Signature do

    before :example do
        @sig_nil = Signature.new nil
        @sig_empty = Signature.new ""
        @sig_simple = Signature.new "simple"
        @sig_var = Signature.new "cmd :variable"
        @sig_tbl = Signature.new "cmd $table"
        @sig_att = Signature.new "cmd #attribute"
    end

    context "#matches?" do
        it "should match at direct match" do
            expect(@sig_simple.matches? "simple").to_not be_nil
        end
    end

    context "#matches_partial?" do
        it "should match for empty input" do
            expect(@sig_empty.matches_partial? "").to eq(true)
            expect(@sig_simple.matches_partial? "").to eq(true)
        end

        it "should not match for different input" do
            expect(@sig_empty.matches_partial? "a").to_not eq(true)
            expect(@sig_simple.matches_partial? "a").to_not eq(true)
        end
    end

    context "#expand" do
        it "should not expand non-variables" do
            expect(@sig_simple.expand 'foobar').to eq([ 'foobar' ])
        end

        it "should expand tables" do
            expect(@sig_simple.expand "$foobar", { foobar: [ 'a', 'b', 'c' ] }).to eq([ "a", "b", "c" ])
        end

        it "should expand attributes" do
            expect(@sig_simple.expand "#foobar", { scope: { foobar: [ 1, 2, 3 ] } }).to eq(['foobar'])
        end

        it "should not expand empty inputs" do
            expect(@sig_simple.expand "").to eq([])
            expect(@sig_simple.expand nil).to eq([])
        end
    end

    context "#extract" do
        it "should extract generic variables" do
            expect(@sig_var.extract "cmd test").to eq({ ':variable' => "test" })
        end

        it "should extract table variables" do
            expect(@sig_tbl.extract "cmd test").to eq({ '$table' => "test" })
        end

        it "should extract attribute variables" do
            expect(@sig_att.extract "cmd test").to eq({ '#attribute' => "test" })
        end
    end

    context "#strict_head_check" do
        it "should only match blablabla whatever i don't care" do
            expect(@sig_simple.strict_head_check [], []).to be_truthy
            expect(@sig_simple.strict_head_check [ "cmd" ], [ "cmd" ]).to be_truthy
        end
    end
end
