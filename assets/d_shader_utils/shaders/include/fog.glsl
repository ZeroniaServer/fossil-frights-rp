float near = 0.1; 
float far  = 1000.0;
float LinearizeDepth(float depth) 
{
    float z = 1. - depth * 2.0;
    return (near * far) / (far + near - z * (far - near));    
}