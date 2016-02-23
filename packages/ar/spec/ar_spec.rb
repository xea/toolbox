require 'ar/ar'

RSpec.describe ActiveRecordService do

    class TestNamespace

        include ActiveRecordNameSpace

        def lookup(model_id)
        end
    end

    context "#lookup" do

        it "should allow accessing registered models" do

            ar = ActiveRecordService.new


        end
    end
end

RSpec.describe ActiveRecordNameSpaceProxy do
end
