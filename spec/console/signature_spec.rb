require 'console/signature'

RSpec.describe Signature do

    before :example do
        @sig_nil = Signature.new nil
        @sig_empty = Signature.new ""
        @sig_simple = Signature.new "simple"
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
end
