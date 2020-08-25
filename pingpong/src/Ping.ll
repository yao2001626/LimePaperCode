; ModuleID = '/home/yaos4/Documents/LimePaperCode/pingpong/src/Ping.c'
source_filename = "/home/yaos4/Documents/LimePaperCode/pingpong/src/Ping.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Ping_struct = type { i32, i32, i32, i32, %struct.Pong_struct*, i32 }
%struct.Pong_struct = type opaque

; Function Attrs: noinline nounwind optnone uwtable
define void @Ping_ping(i32, %struct.Ping_struct*, i8*) #0 {
  %4 = alloca i32, align 4
  %5 = alloca %struct.Ping_struct*, align 8
  %6 = alloca i8*, align 8
  store i32 %0, i32* %4, align 4
  store %struct.Ping_struct* %1, %struct.Ping_struct** %5, align 8
  store i8* %2, i8** %6, align 8
  %7 = load i32, i32* %4, align 4
  %8 = load %struct.Ping_struct*, %struct.Ping_struct** %5, align 8
  %9 = getelementptr inbounds %struct.Ping_struct, %struct.Ping_struct* %8, i32 0, i32 5
  store i32 %7, i32* %9, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @Ping_pong(%struct.Ping_struct*, i8*) #0 {
  %3 = alloca %struct.Ping_struct*, align 8
  %4 = alloca i8*, align 8
  store %struct.Ping_struct* %0, %struct.Ping_struct** %3, align 8
  store i8* %1, i8** %4, align 8
  %5 = load %struct.Ping_struct*, %struct.Ping_struct** %3, align 8
  %6 = load %struct.Ping_struct*, %struct.Ping_struct** %3, align 8
  %7 = getelementptr inbounds %struct.Ping_struct, %struct.Ping_struct* %6, i32 0, i32 5
  %8 = load i32, i32* %7, align 8
  %9 = sub nsw i32 %8, 1
  %10 = load %struct.Ping_struct*, %struct.Ping_struct** %3, align 8
  %11 = getelementptr inbounds %struct.Ping_struct, %struct.Ping_struct* %10, i32 0, i32 4
  %12 = load %struct.Pong_struct*, %struct.Pong_struct** %11, align 8
  %13 = load i8*, i8** %4, align 8
  call void @Pong_pong(%struct.Ping_struct* %5, i32 %9, %struct.Pong_struct* %12, i8* %13)
  %14 = load %struct.Ping_struct*, %struct.Ping_struct** %3, align 8
  %15 = getelementptr inbounds %struct.Ping_struct, %struct.Ping_struct* %14, i32 0, i32 5
  store i32 0, i32* %15, align 8
  ret void
}

declare void @Pong_pong(%struct.Ping_struct*, i32, %struct.Pong_struct*, i8*) #1

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
