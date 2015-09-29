require 'console/buffer'

RSpec.describe LineBuffer do

    before :example do
        @buffer = LineBuffer.new
    end

    context '#set' do
        it "should replace any previous content in the buffer" do
            @buffer.set('test content', 0)
            @buffer.set('bar', 0)
            expect(@buffer.to_s).to eq('bar')

            @buffer.set('test', 0)
            expect(@buffer.to_s).to eq('test')
        end

        it "should set the cursor to the specified position" do
            old = 'test content'
            new = 'bar'
            expect(@buffer.set(old, 0)).to eq("#{old}#{CHAR_LEFT * old.length}")
            expect(@buffer.set(new, 0)).to eq("#{new}#{' ' * (old.length - new.length)}#{CHAR_LEFT * old.length}")
            #expect(@buffer.set(new, 2)).to eq("#{new}#{CHAR_LEFT * (new.length - 2)}")
        end
    end
end
