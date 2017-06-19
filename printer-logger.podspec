Pod::Spec.new do |s|
s.name             = 'printer-logger'
s.module_name      = 'Printer'
s.version          = '1.3'
s.summary          = 'Printer is just another logger but fancy. ✅❌🚧📣🚨'
s.description      = 'Want to print logs in a fancy way? Here is the Swift 3.x supported logger for you. We calls it – Printer 🖨'
s.homepage         = 'https://github.com/hemangshah/printer'
s.license          = 'MIT'
s.author           = { 'hemangshah' => 'hemangshah.in@gmail.com' }
s.source           = { :git => 'https://github.com/hemangshah/printer.git', :tag => s.version.to_s }
s.platform     = :ios, '9.0'
s.requires_arc = true
s.source_files = 'PrinterExampleApp/PrinterExampleApp/Printer/*.swift'
s.resources = 'PrinterExampleApp/PrinterExampleApp/Printer/*.storyboard'
end
