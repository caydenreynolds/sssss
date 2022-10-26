mod utils;

use std::io::Write;
use brotli::enc::BrotliEncoderParams;
use wasm_bindgen::prelude::*;

use sha3::digest::{ExtendableOutput, Update, XofReader};
use sha3::Shake128;

// use web_sys::{Request, RequestInit, RequestMode};

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
pub fn crypto_hash(data: String) -> Vec<u8> {
    let mut hasher = Shake128::default();
    hasher.update(data.as_bytes());
    let mut reader = hasher.finalize_xof();
    // Use 72 bits because that's the maximum password length the server-side bcrypt algorithm can accept
    let mut result = [0u8; 72];
    reader.read(&mut result);
    return result.to_vec();
}

// #[wasm_bindgen]
// pub fn compress(mut input: Vec<u8>) -> Vec<u8> {
//     let mut output = Vec::new();
//     let params = BrotliEncoderParams::default();
//     brotli::BrotliCompress(&mut input, &mut output, &encoder_params).unwrap();
//     return output;
// }
//
// #[wasm_bindgen]
// pub fn decompress(arr: Vec<u8>, buffer_size: usize) -> Vec<u8> {
//     let mut output = Vec::new();
//     {
//         let mut writer = brotli::DecompressorWriter::new(&mut output, buffer_size);
//         writer.write(&arr).unwrap();
//     }
//     return (&output[..]).into();
// }

// #[wasm_bindgen]
// pub fn add(a: u8, b: u8) -> u8 {
//     a + b
// }
//
// // #[wasm_bindgen]
// // extern {
// //     fn alert(s: &str);
// // }
// //
// // #[wasm_bindgen]
// // pub fn greet() {
// //     alert("Hello, fang!");
// // }
//
// #[wasm_bindgen]
// pub fn str_pass_through(s: String) -> String {
//     String::from(s)
// }
//
// #[derive(Serialize)]
// struct SampleSendMsg<'a> {
//     auth_token: &'a str,
//     req_type: i8,
//     file_name: &'a str,
//     search_string: &'a str,
//     directory: &'a str,
//     username: &'a str,
//     password: &'a str,
// }
//
// #[wasm_bindgen]
// pub fn to_json(
//     auth_token: &str,
//     req_type: i8,
//     file_name: &str,
//     search_string: &str,
//     directory: &str,
//     username: &str,
//     password: &str,
//     times: usize,
// ) -> String {
//     for i in 1..times {
//         let msg = SampleSendMsg {
//             auth_token,
//             req_type,
//             file_name,
//             search_string,
//             directory,
//             username,
//             password,
//         };
//
//         serde_json::to_string(&msg).unwrap();
//     }
//     let msg = SampleSendMsg {
//         auth_token,
//         req_type,
//         file_name,
//         search_string,
//         directory,
//         username,
//         password,
//     };
//
//     serde_json::to_string(&msg).unwrap()
// }
//
// #[wasm_bindgen]
// pub fn deflateFang(bytes: &[u8]) -> Vec<u8> {
//     deflate::deflate_bytes(bytes)
// }

//
// pub fn make_request(
//     auth_token: &str,
//     req_type: i8,
//     file_name: &str,
//     search_string: &str,
//     directory: &str,
//     username: &str,
//     password: &str,
// ) -> String {
//     let json = to_json(auth_token, req_type, file_name, search_string, directory, username, password, 1);
//     let mut opts = RequestInit::new();
//     opts.method("GET");
//     opts.mode(RequestMode::Cors);
//     let url = "https://perry:42069/small.txt";
//     let request = Request::new_with_str_and_init(&url, &opts)?;
//     // reqwest_wasm::blocking::get().text().unwrap()
// }
