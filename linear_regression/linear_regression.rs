#[no_mangle]
pub extern "C" fn linear_regression_rs(x: *const f32, y: *const f32, n: usize, slope: *mut f32, intercept: *mut f32) {
    let mut sum_xy = 0.0;
    let mut sum_x = 0.0;
    let mut sum_y = 0.0;
    let mut sum_x_squared = 0.0;

    unsafe {
        for i in 0..n {
            let xi = *x.offset(i as isize);
            let yi = *y.offset(i as isize);
            sum_xy += xi * yi;
            sum_x += xi;
            sum_y += yi;
            sum_x_squared += xi * xi;
        }

        let slope_val = (n as f32 * sum_xy - sum_x * sum_y) / (n as f32 * sum_x_squared - sum_x * sum_x);
        let intercept_val = (sum_y - slope_val * sum_x) / n as f32;

        *slope = slope_val;
        *intercept = intercept_val;
    }
}
