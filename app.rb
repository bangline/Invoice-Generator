# Generates the invoice PDF based on user input
require 'prawn'
require 'prawn/layout'
require 'csv'

class App

  MY_LOGO = "logo.png"

  def run
    client = get_client_name
    invoice_ref = get_invoice_number
    invoice_date = Time.now.strftime("%d/%m/%Y")
    timesheet = Timesheet.new(get_csv)
    
    Prawn::Document.generate("#{invoice_ref}.pdf") do
      font_size 22
      text "Invoice: #{invoice_ref}", :position => :left, :vposition => :top
      font_size 12
      move_down 5
      text "#{client} - #{invoice_date}"
      image MY_LOGO, :scale => 0.5, :position => :right,  :vposition => :top
      move_down 6
      text "Payment terms: 30 days"
      move_down 30

      invoice_headers = ["Date", "Description", "Hours/Qty", "Cost"]
      table timesheet.items, :border_style => :grid, :headers => invoice_headers,
        :header_color => "000000", :header_text_color =>"FFFFFF",
        :row_colors => ["FFFFFF","efefff"], :width => bounds.width

      move_down 30
      text "Total ammount payable: #{timesheet.grand_total}"
      move_down 8
      text "Please make cheques payable to David Kennedy\nThank you"
    end

  end

  def get_client_name
    print "Client: "
    gets.chomp
  end

  def get_invoice_number
    print "Invoice number: "
    gets.chomp
  end

  def get_csv
    printf "Timesheet: "
    gets.chomp
  end

  class Timesheet
    attr_reader :items

    MY_RATE = 18.0
    
    def initialize(file)
      @items = []
      @total_hours = 0.0
      @grand_total = 0.0
      CSV.foreach(file, headers: true, converters: :numeric) do |data|
        cost_sub = sub_total(data)
        @items << [ data["Date"], data["Description"], float_format(data["Time"]), cost_sub ]
        @grand_total += cost_sub.to_f
      end
    end

    def float_format(value)
		unless value.nil?
			'%.2f' % value
		end
    end

    def sub_total(data)
      if data["Time"] == nil
        float_format data["Cost"]
      else
        float_format(data["Time"] * MY_RATE)
      end
    end

    def grand_total
      float_format @grand_total
    end
    
  end

end

app = App.new
app.run