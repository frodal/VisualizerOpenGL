#include "PreCompiledHeader.h"
#include "Test3DCube.h"
#include "Renderer.h"
#include "Window.h"

namespace Test {

	Test3DCube::Test3DCube(std::string& name)
		: Test(name), projection(glm::ortho(-640.0f, 640.0f, -360.0f, 360.0f, 0.1f, 1000.0f)),
		view(glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, 0.0f, -500.0f))),
		model(glm::mat4(1.0f)), size(100.0f), speed(1.0f), rotationAngle(0),
		cubeColor{ 0.2f, 0.2f, 0.2f, 1.0f },
		backgroundColor{ 0.7f, 0.7f, 0.7f, 1.0f }
	{
		/* Vertex positions*/
		float positions[] = {
			 -1.0f,-1.0f,-1.0f, // 0
			  1.0f,-1.0f,-1.0f, // 1
			  1.0f, 1.0f,-1.0f, // 2
			 -1.0f, 1.0f,-1.0f, // 3

			 -1.0f,-1.0f, 1.0f, // 4
			  1.0f,-1.0f, 1.0f, // 5
			  1.0f, 1.0f, 1.0f, // 6
			 -1.0f, 1.0f, 1.0f  // 7
		};

		/* Triangle vertex indices (position[index])*/
		unsigned int indices[] = {
			0, 1, 2,
			2, 3, 0, // -z

			4, 7, 6,
			6, 5, 4, // +z

			0, 3, 7,
			7, 4, 0, // -x

			1, 5, 6,
			6, 2, 1, // +x

			0, 4, 5,
			5, 1, 0, // -y

			3, 2, 6,
			6, 7, 3  // +y
		};

		Renderer renderer;
		renderer.EnableBlend();
		renderer.EnableDepth();

		vertexArray = std::make_unique<VertexArray>();
		vertexBuffer = std::make_unique<VertexBuffer>(positions, sizeof(positions));
		VertexBufferLayout bufferLayout;
		bufferLayout.Push<float>(3);
		vertexArray->AddBuffer(*vertexBuffer, bufferLayout);

		indexBuffer = std::make_unique<IndexBuffer>(indices, lengthof(indices));

		shader = std::make_unique<Shader>("resources/shaders/ClearColor.glsl");
	}

	Test3DCube::~Test3DCube()
	{
	}

	void Test3DCube::OnUpdate(float deltaTime)
	{
		// Update projection matrix with latest viewport size
		float halfWidth = static_cast<float>(window->GetWidth()) / 2.0f;
		float halfHeight = static_cast<float>(window->GetHeight()) / 2.0f;
		projection = glm::ortho(-halfWidth, halfWidth, -halfHeight, halfHeight, 0.1f, 1000.0f);

		// Update model scale and rotation
		model = glm::scale(glm::mat4(1.0f), glm::vec3(size, size, size)); // Scales the model
		rotationAngle += deltaTime * speed;
		model = glm::rotate(model, rotationAngle, glm::vec3(1.0f, 1.0f, 0.0f)); // rotates the model about the vector (1,1,0)
	}

	void Test3DCube::OnRender()
	{
		Renderer renderer;
		renderer.SetClearColor(backgroundColor[0], backgroundColor[1], backgroundColor[2], backgroundColor[3]);
		renderer.Clear();
		
		// Rendering cube
		shader->Bind();
		shader->SetUniformMat4f("u_MVP", projection * view * model);
		shader->SetUniform4f("u_Color", cubeColor[0], cubeColor[1], cubeColor[2], cubeColor[3]);

		renderer.Draw(*vertexArray, *indexBuffer, *shader);

		// Rendering cube wire-frame
		model = glm::scale(model, glm::vec3(1.005f, 1.005f, 1.005f)); // Scales the model
		shader->SetUniformMat4f("u_MVP", projection * view * model);
		shader->SetUniform4f("u_Color", 0.0f, 0.0f, 0.0f, 1.0f);

		renderer.DrawWireFrame(*vertexArray, *indexBuffer, *shader);
	}

	void Test3DCube::OnImGuiRender()
	{
		ImGui::SliderFloat("Cube size", &size, 0.0f, 200.0f);
		ImGui::SliderFloat("Rotation speed", &speed, 0.0f, 10.0f);
		ImGui::ColorEdit4("Cube color", cubeColor);
		ImGui::ColorEdit4("Background color", backgroundColor);
		ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
	}
}