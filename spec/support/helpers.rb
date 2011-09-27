module AdapterGenerator
  module Spec
    module Helpers
      # Ripped this off directly from thor, which defines it in spec_helper.rb where it can't be reused directly :(
      def capture(stream)
        begin
          stream = stream.to_s
          eval "$#{stream} = StringIO.new"
          yield
          result = eval("$#{stream}").string
        ensure
          eval("$#{stream} = #{stream.upcase}")
        end

        result
      end
    end
  end
end

