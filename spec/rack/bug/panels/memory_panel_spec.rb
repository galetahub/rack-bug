require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

class Rack::Bug
  describe MemoryPanel do    
    describe "heading" do
      it "displays the total memory" do
        response = get "/", {}, {"rack-bug.panel_classes" => [MemoryPanel]}
        response.should have_heading(/\d+ KB total/)
      end
      
      it "displays the memory change during the request" do
        response = get "/", {}, {"rack-bug.panel_classes" => [MemoryPanel]}
        response.should have_heading(/\d+ KB Δ/)
      end
    end
  end
end