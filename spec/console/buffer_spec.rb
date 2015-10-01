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

    context '#type' do
        it 'should append characters to the current cursor position' do
            @buffer.type 'a'
            expect(@buffer.to_s).to eq('a')
            @buffer.type 'i'
            expect(@buffer.to_s).to eq('ai')
            @buffer.type 'c'
            expect(@buffer.to_s).to eq('aic')
            @buffer.type 'u'
            expect(@buffer.to_s).to eq('aicu')
            @buffer.type 'l'
            expect(@buffer.to_s).to eq('aicul')
            @buffer.type 'd'
            expect(@buffer.to_s).to eq('aiculd')
            @buffer.cursor_left
            @buffer.type 'e'
            expect(@buffer.to_s).to eq('aiculed')
            @buffer.cursor_right
            @buffer.type 's'
            expect(@buffer.to_s).to eq('aiculeds')
        end
    end

    context '#cursor_left' do
        it 'should not move if the buffer is empty' do
            expect(@buffer.cursor_left).to eq("")
            expect(@buffer.idx).to eq(0)
        end

        it 'should move one characters left by default' do
            @buffer.print 'foobar'
            expect(@buffer.cursor_left).to eq(CHAR_LEFT)
            expect(@buffer.idx).to eq(5)
        end

        it 'should move the specified amount of characters' do
            @buffer.print 'foobar'
            expect(@buffer.cursor_left 2).to eq(CHAR_LEFT * 2)
            expect(@buffer.idx).to eq(4)
        end

        it 'should never move past the leftmost position' do
            @buffer.print 'foobar'
            @buffer.cursor_left 3 # cursor at 'b'
            expect(@buffer.cursor_left 5).to eq(CHAR_LEFT * 3)
            expect(@buffer.idx).to eq(0)
        end
    end

    context '#cursor_right' do
        it 'should never move past the rightmost position' do
            @buffer.print 'foobar'
            expect(@buffer.cursor_right).to eq('')
            expect(@buffer.idx).to eq(6)

            expect(@buffer.cursor_right 3).to eq('')
            expect(@buffer.idx).to eq(6)

            @buffer.cursor_left

            expect(@buffer.cursor_right).to eq(CHAR_RIGHT)
            expect(@buffer.idx).to eq(6)

            @buffer.cursor_left 2

            expect(@buffer.cursor_right 4).to eq(CHAR_RIGHT * 2)
            expect(@buffer.idx).to eq(6)
        end
    end

    context '#complete' do
        it 'should complete with the first element' do
            @buffer.complete [ 'foobar' ]
            expect(@buffer.to_s).to eq('foobar ')
        end
    end

    context '#delete' do
        it 'should delete the specified number of characters from the current position' do
            @buffer.print 'aiculedssul'
            @buffer.cursor_left
            @buffer.delete
            expect(@buffer.to_s).to eq('aiculedssu')
            @buffer.cursor_left 30
            @buffer.delete
            expect(@buffer.to_s).to eq('iculedssu')
        end

        it 'should not delete anything when the cursor is at the end of the buffer' do
            @buffer.print 'aiculedssul'
            @buffer.delete
            expect(@buffer.to_s).to eq('aiculedssul')
        end
    end

    context '#delete_back' do
    end
end
