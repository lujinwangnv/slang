// byte-address-buffer-array.slang
//TEST(compute, vulkan):COMPARE_COMPUTE_EX(filecheck-buffer=CHECK):-slang -compute -d3d12 -profile cs_6_0 -use-dxil -shaderobj -output-using-type
//DISABLED_TEST(compute, vulkan):COMPARE_COMPUTE_EX(filecheck-buffer=CHECK):-slang -compute -vk -shaderobj -output-using-type

//TEST:SIMPLE(filecheck=CHECK2):-target hlsl -entry computeMain -stage compute
//TEST:SIMPLE(filecheck=CHECK3):-target spirv -entry computeMain -stage compute
//TEST:SIMPLE(filecheck=CHECK3):-target spirv -emit-spirv-directly -entry computeMain -stage compute

// Confirm compilation of `(RW)ByteAddressBuffer` with aligned load / stores to wider data types.

//TEST_INPUT:ubuffer(data=[0 0 0 0], stride=4):out,name=buffer
[vk::binding(2, 3)] RWByteAddressBuffer buffer;
struct Block {
    float4 val[2];
};
[shader("compute")]
[numthreads(1,1,1)]
void computeMain(uint3 threadId : SV_DispatchThreadID)
{
    // CHECK-NOT: warning

    // CHECK2: float4 {{.*}}[int(2)] = (buffer_0).Load<float4 [int(2)] >(0U);
    // CHECK2: buffer_0.Store(0U,{{.*}});
    // CHECK2: float {{.*}} = (buffer_0).Load<float >(4U);
    // CHECK2: float {{.*}} = (buffer_0).Load<float >(8U);
    // CHECK2: float {{.*}} = (buffer_0).Load<float >(12U);
    // CHECK2: float {{.*}} = (buffer_0).Load<float >(16U);
    // CHECK2: float4 {{.*}} = float4({{.*}}, {{.*}}, {{.*}}, {{.*}});
    // CHECK2: float4 {{.*}} = (buffer_0).Load<float4 >(20U);
    // CHECK2: buffer_0.Store(16U,{{.*}});
    // CHECK2: buffer_0.Store(32U,{{.*}});

    // CHECK3: OpAccessChain
    // CHECK3: OpLoad %v4float
    // CHECK3: OpStore
    buffer.Store(0, buffer.LoadAligned<Block>(0));
    buffer.StoreAligned(16, buffer.LoadAligned<Block>(4, 16));
}

