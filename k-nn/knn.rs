use std::slice;

fn insertion_sort(arr: &mut [f64], n: usize) {
    for i in 1..n {
        let mut key = [0.0; 4];
        key.copy_from_slice(&arr[i * 4..(i + 1) * 4]);
        let mut j = i;
        while j > 0 && arr[(j - 1) * 4 + 2] > key[2] {
            for idx in 0..4 {
                arr[j * 4 + idx] = arr[(j - 1) * 4 + idx];
            }
            j -= 1;
        }
        for idx in 0..4 {
            arr[j * 4 + idx] = key[idx];
        }
    }
}


#[no_mangle]
pub extern "C" fn knn_rs(points: *mut f64, n: usize, k: usize, p: *const f64) -> i32 {
    let points_slice = unsafe { slice::from_raw_parts_mut(points, n * 4) };
    let p_slice = unsafe { slice::from_raw_parts(p, 2) };

    for i in 0..n {
        let dx = points_slice[i * 4] - p_slice[0];
        let dy = points_slice[i * 4 + 1] - p_slice[1];
        points_slice[i * 4 + 2] = (dx * dx + dy * dy).sqrt();
    }

    insertion_sort(points_slice, n);

    let mut freq0 = 0;
    let mut freq1 = 0;

    for i in 0..k {
        if points_slice[i * 4 + 3] == 0.0 {
            freq0 += 1;
        } else if points_slice[i * 4 + 3] == 1.0 {
            freq1 += 1;
        }
    }

    if freq0 > freq1 {
        0
    } else {
        1
    }
}
