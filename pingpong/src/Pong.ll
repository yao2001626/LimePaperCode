; ModuleID = '/home/yaos4/Documents/LimePaperCode/pingpong/src/Pong.c'
source_filename = "/home/yaos4/Documents/LimePaperCode/pingpong/src/Pong.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.Ping_struct = type opaque
%struct.Pong_struct = type { i32, i32, i32, i32, %struct.Ping_struct*, i32 }

; Function Attrs: noinline nounwind optnone uwtable
define void @Pong_pong(%struct.Ping_struct*, i32, %struct.Pong_struct*, i8*) #0 {
  %5 = alloca %struct.Ping_struct*, align 8
  %6 = alloca i32, align 4
  %7 = alloca %struct.Pong_struct*, align 8
  %8 = alloca i8*, align 8
  store %struct.Ping_struct* %0, %struct.Ping_struct** %5, align 8
  store i32 %1, i32* %6, align 4
  store %struct.Pong_struct* %2, %struct.Pong_struct** %7, align 8
  store i8* %3, i8** %8, align 8
  %9 = load %struct.Ping_struct*, %struct.Ping_struct** %5, align 8
  %10 = load %struct.Pong_struct*, %struct.Pong_struct** %7, align 8
  %11 = getelementptr inbounds %struct.Pong_struct, %struct.Pong_struct* %10, i32 0, i32 4
  store %struct.Ping_struct* %9, %struct.Ping_struct** %11, align 8
  %12 = load i32, i32* %6, align 4
  %13 = load %struct.Pong_struct*, %struct.Pong_struct** %7, align 8
  %14 = getelementptr inbounds %struct.Pong_struct, %struct.Pong_struct* %13, i32 0, i32 5
  store i32 %12, i32* %14, align 8
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define void @Pong_ping(%struct.Pong_struct*, i8*) #0 {
  %3 = alloca %struct.Pong_struct*, align 8
  %4 = alloca i8*, align 8
  store %struct.Pong_struct* %0, %struct.Pong_struct** %3, align 8
  store i8* %1, i8** %4, align 8
  %5 = load %struct.Pong_struct*, %struct.Pong_struct** %3, align 8
  %6 = getelementptr inbounds %struct.Pong_struct, %struct.Pong_struct* %5, i32 0, i32 5
  %7 = load i32, i32* %6, align 8
  %8 = load %struct.Pong_struct*, %struct.Pong_struct** %3, align 8
  %9 = getelementptr inbounds %struct.Pong_struct, %struct.Pong_struct* %8, i32 0, i32 4
  %10 = load %struct.Ping_struct*, %struct.Ping_struct** %9, align 8
  %11 = load i8*, i8** %4, align 8
  call void @Ping_ping(i32 %7, %struct.Ping_struct* %10, i8* %11)
  %12 = load %struct.Pong_struct*, %struct.Pong_struct** %3, align 8
  %13 = getelementptr inbounds %struct.Pong_struct, %struct.Pong_struct* %12, i32 0, i32 5
  store i32 0, i32* %13, align 8
  ret void
}

declare void @Ping_ping(i32, %struct.Ping_struct*, i8*) #1

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
