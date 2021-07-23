// This file is generated by rust-protobuf 2.22.1. Do not edit
// @generated

// https://github.com/rust-lang/rust-clippy/issues/702
#![allow(unknown_lints)]
#![allow(clippy::all)]

#![allow(unused_attributes)]
#![cfg_attr(rustfmt, rustfmt::skip)]

#![allow(box_pointers)]
#![allow(dead_code)]
#![allow(missing_docs)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]
#![allow(trivial_casts)]
#![allow(unused_imports)]
#![allow(unused_results)]
//! Generated file from `event.proto`

/// Generated files are compatible only with the same version
/// of protobuf runtime.
// const _PROTOBUF_VERSION_CHECK: () = ::protobuf::VERSION_2_22_1;

#[derive(Clone,PartialEq,Eq,Debug,Hash)]
pub enum EditorEvent {
    CreateDoc = 0,
}

impl ::protobuf::ProtobufEnum for EditorEvent {
    fn value(&self) -> i32 {
        *self as i32
    }

    fn from_i32(value: i32) -> ::std::option::Option<EditorEvent> {
        match value {
            0 => ::std::option::Option::Some(EditorEvent::CreateDoc),
            _ => ::std::option::Option::None
        }
    }

    fn values() -> &'static [Self] {
        static values: &'static [EditorEvent] = &[
            EditorEvent::CreateDoc,
        ];
        values
    }

    fn enum_descriptor_static() -> &'static ::protobuf::reflect::EnumDescriptor {
        static descriptor: ::protobuf::rt::LazyV2<::protobuf::reflect::EnumDescriptor> = ::protobuf::rt::LazyV2::INIT;
        descriptor.get(|| {
            ::protobuf::reflect::EnumDescriptor::new_pb_name::<EditorEvent>("EditorEvent", file_descriptor_proto())
        })
    }
}

impl ::std::marker::Copy for EditorEvent {
}

impl ::std::default::Default for EditorEvent {
    fn default() -> Self {
        EditorEvent::CreateDoc
    }
}

impl ::protobuf::reflect::ProtobufValue for EditorEvent {
    fn as_ref(&self) -> ::protobuf::reflect::ReflectValueRef {
        ::protobuf::reflect::ReflectValueRef::Enum(::protobuf::ProtobufEnum::descriptor(self))
    }
}

static file_descriptor_proto_data: &'static [u8] = b"\
    \n\x0bevent.proto*\x1c\n\x0bEditorEvent\x12\r\n\tCreateDoc\x10\0JS\n\x06\
    \x12\x04\0\0\x04\x01\n\x08\n\x01\x0c\x12\x03\0\0\x12\n\n\n\x02\x05\0\x12\
    \x04\x02\0\x04\x01\n\n\n\x03\x05\0\x01\x12\x03\x02\x05\x10\n\x0b\n\x04\
    \x05\0\x02\0\x12\x03\x03\x04\x12\n\x0c\n\x05\x05\0\x02\0\x01\x12\x03\x03\
    \x04\r\n\x0c\n\x05\x05\0\x02\0\x02\x12\x03\x03\x10\x11b\x06proto3\
";

static file_descriptor_proto_lazy: ::protobuf::rt::LazyV2<::protobuf::descriptor::FileDescriptorProto> = ::protobuf::rt::LazyV2::INIT;

fn parse_descriptor_proto() -> ::protobuf::descriptor::FileDescriptorProto {
    ::protobuf::Message::parse_from_bytes(file_descriptor_proto_data).unwrap()
}

pub fn file_descriptor_proto() -> &'static ::protobuf::descriptor::FileDescriptorProto {
    file_descriptor_proto_lazy.get(|| {
        parse_descriptor_proto()
    })
}
