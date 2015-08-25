require "console"

RSpec.describe Console do

    before :example do
        @console = Console.new
    end

    context "#gen_prompt" do
        it "should always return a string" do
            expect(@console.gen_prompt).to_not be_nil
            expect(@console.gen_prompt.class).to be(String)
        end
    end

    context "#read_input" do
    end

    context "#process_input" do
    end
end
