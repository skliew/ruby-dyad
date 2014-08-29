require "dyad/version"
require "ffi"
require "ffi-compiler/loader"

module Dyad
  extend FFI::Library
  ffi_lib FFI::Compiler::Loader.find('dyad')

  def self.dyad_attach_function(c_name, args, returns)
    name = c_name.to_s.sub(/^dyad_/, '').gsub(/([A-Z])/, "_\\1").downcase.to_sym
    attach_function name, c_name, args, returns
    name
  end

  enum :event, [
    :EVENT_NULL,
    :EVENT_DESTROY,
    :EVENT_ACCEPT,
    :EVENT_LISTEN,
    :EVENT_CONNECT,
    :EVENT_CLOSE,
    :EVENT_READY,
    :EVENT_DATA,
    :EVENT_LINE,
    :EVENT_ERROR,
    :EVENT_TIMEOUT,
    :EVENT_TICK
  ]

  enum :state, [
    :STATE_CLOSED,
    :STATE_CLOSING,
    :STATE_CONNECTING,
    :STATE_CONNECTED,
    :STATE_LISTENING
  ]

  class Event < FFI::Struct
    layout :type, :int,
      :udata, :pointer,
      :stream, :pointer,
      :remote, :pointer,
      :msg, :pointer,
      :data, :pointer,
      :length, :int

    def method_missing(name)
      field = self[name]
      if name == :remote || name == :stream
        return Stream.new(field)
      elsif name == :data
        return field.read_string(self[:length])
      end
      field
    end
  end

  class Stream
    def self.attach_function(c_name, args, returns)
      name = Dyad.dyad_attach_function(c_name, args, returns)
      define_method(name) do |*args|
        Dyad.send(name, @stream, *args)
      end
    end

    def initialize(stream = nil)
      @stream = stream
      @stream ||= Dyad.dyad_newStream
    end

    def add_listener(event, &client_callback)
      callback = Proc.new do |event|
        client_event = Dyad::Event.new event
        client_callback.call(client_event)
      end
      # dyad provides a param udata, which would be set into
      # an event's udata field when a callback occurs. We do
      # not provide a way to set udata here as in Ruby,
      # Procs and lambdas provide closures, which
      # provide the same funtionality.
      Dyad.dyad_addListener(@stream, event, callback, nil)
    end

    def write(data, size=nil)
      size = data.size if size.nil?

      pointer = FFI::MemoryPointer.new(:string, size)
      
      Dyad.dyad_write(@stream, data, size)
    end

    def listen(port)
      Dyad.dyad_listen(@stream, port)
    end
  end

  callback :dyad_callback, [:pointer], :void

  dyad_attach_function :dyad_init, [], :void
  dyad_attach_function :dyad_update,[], :void
  dyad_attach_function :dyad_shutdown,[], :void
  dyad_attach_function :dyad_getVersion, [], :pointer
  dyad_attach_function :dyad_getTime, [], :double
  dyad_attach_function :dyad_getStreamCount, [], :int

  # We'll wrap the following functions with Stream
  # to make our APIs look more Rubyish
  attach_function :dyad_newStream, [], :pointer
  attach_function :dyad_listen, [:pointer, :int], :int
  attach_function :dyad_listenEx, [:pointer, :string, :int, :int], :int
  attach_function :dyad_addListener, [:pointer, :event, :dyad_callback, :pointer], :void
  attach_function :dyad_removeListener, [:pointer, :event, :dyad_callback, :pointer], :void
  attach_function :dyad_removeAllListeners, [:pointer, :event], :void
  attach_function :dyad_write, [:pointer, :pointer, :int], :pointer
  attach_function :dyad_writef, [:pointer, :string, :varargs], :pointer

  # We can't use dyad_vwritef because 'ffi' does not support va_list yet. 
  # attach_function :dyad_vwritef, [:pointer, :string, :varargs], :pointer

  Stream.attach_function :dyad_setTimeout, [:pointer, :double], :void
  Stream.attach_function :dyad_setNoDelay, [:pointer, :int], :void
  Stream.attach_function :dyad_getState, [:pointer], :void
  Stream.attach_function :dyad_getAddress, [:pointer], :string
  Stream.attach_function :dyad_getPort, [:pointer], :int
  Stream.attach_function :dyad_getBytesSent, [:pointer], :int
  Stream.attach_function :dyad_getBytesReceived, [:pointer], :int
  Stream.attach_function :dyad_getSocket, [:pointer], :int
  Stream.attach_function :dyad_connect, [:pointer, :string, :int], :int
  Stream.attach_function :dyad_close, [:pointer], :int
  Stream.attach_function :dyad_end, [:pointer], :void

end

