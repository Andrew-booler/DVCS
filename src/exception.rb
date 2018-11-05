def foo
	p "Before the raise"
	raise "an err occured"
	p "After the raise"
end

begin
	foo
rescue
	p "I'm rescured"
end
