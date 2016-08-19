require 'ar/ar'

RSpec.describe ARQLVM do

    context '#initialize' do
        it 'should create a new, blank VM' do
            vm = ARQLVM.new
        end
    end

    context '#push' do
        it 'should push a new item onto the top of the stack' do
            vm = ARQLVM.new

            vm.push :test
            expect(vm.pop).to eq(:test)
        end
    end

    context '#apply' do
        it 'should apply the given lambda to the top n elements of the stack' do
            vm = ARQLVM.new

            vm.push 1
            vm.push 3
            vm.apply { |a, b| a + b }
            expect(vm.pop).to eq(4)
            expect(vm.empty?).to be_truthy
        end

        it 'should push every element back after evaluation' do
            vm = ARQLVM.new

            vm.push 1
            vm.push 3
            vm.push -4
            vm.apply { |a| [ 2, 5 ] }
            expect(vm.pop(4)).to eq([1, 3, [ 2, 5 ] ])
            expect(vm.empty?).to be_truthy
        end

        it 'should work well with arrays' do
            vm = ARQLVM.new

            vm.push 1
            vm.push [ 3, 4, 5 ]
            vm.apply { |a| a.map { |b| b + 1 } }
            expect(vm.pop(2)).to eq([1, [4, 5, 6]])
        end
    end
end
