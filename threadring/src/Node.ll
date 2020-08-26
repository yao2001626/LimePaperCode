; ModuleID = '/home/yaos4/Documents/LimePaperCode/threadring/src/Node.c'
source_filename = "/home/yaos4/Documents/LimePaperCode/threadring/src/Node.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Node_struct = type { i32, i32, i32, i32, %struct.Node_struct*, i32 }

; Function Attrs: noinline nounwind optnone uwtable
define void @Node_pass(i32, %struct.Node_struct*, i8*) #0 {
  %4 = alloca i32, align 4
  %5 = alloca %struct.Node_struct*, align 8
  %6 = alloca i8*, align 8
  store i32 %0, i32* %4, align 4
  store %struct.Node_struct* %1, %struct.Node_struct** %5, align 8
  store i8* %2, i8** %6, align 8
  %7 = load i32, i32* %4, align 4
  %8 = load %struct.Node_struct*, %struct.Node_struct** %5, align 8
  %9 = getelementptr inbounds %struct.Node_struct, %struct.Node_struct* %8, i32 0, i32 5
  store i32 %7, i32* %9, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @Node_setNext(%struct.Node_struct*, %struct.Node_struct*, i8*) #0 {
  %4 = alloca %struct.Node_struct*, align 8
  %5 = alloca %struct.Node_struct*, align 8
  %6 = alloca i8*, align 8
  store %struct.Node_struct* %0, %struct.Node_struct** %4, align 8
  store %struct.Node_struct* %1, %struct.Node_struct** %5, align 8
  store i8* %2, i8** %6, align 8
  %7 = load %struct.Node_struct*, %struct.Node_struct** %4, align 8
  %8 = load %struct.Node_struct*, %struct.Node_struct** %5, align 8
  %9 = getelementptr inbounds %struct.Node_struct, %struct.Node_struct* %8, i32 0, i32 4
  store %struct.Node_struct* %7, %struct.Node_struct** %9, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @Node_forward(%struct.Node_struct*, i8*) #0 {
  %3 = alloca %struct.Node_struct*, align 8
  %4 = alloca i8*, align 8
  store %struct.Node_struct* %0, %struct.Node_struct** %3, align 8
  store i8* %1, i8** %4, align 8
  %5 = load %struct.Node_struct*, %struct.Node_struct** %3, align 8
  %6 = getelementptr inbounds %struct.Node_struct, %struct.Node_struct* %5, i32 0, i32 5
  %7 = load i32, i32* %6, align 8
  %8 = sub nsw i32 %7, 1
  %9 = load %struct.Node_struct*, %struct.Node_struct** %3, align 8
  %10 = getelementptr inbounds %struct.Node_struct, %struct.Node_struct* %9, i32 0, i32 4
  %11 = load %struct.Node_struct*, %struct.Node_struct** %10, align 8
  %12 = load i8*, i8** %4, align 8
  call void @Node_pass(i32 %8, %struct.Node_struct* %11, i8* %12)
  %13 = load %struct.Node_struct*, %struct.Node_struct** %3, align 8
  %14 = getelementptr inbounds %struct.Node_struct, %struct.Node_struct* %13, i32 0, i32 5
  store i32 0, i32* %14, align 8
  ret void
}

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
