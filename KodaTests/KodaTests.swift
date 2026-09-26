import SwiftData
import Testing
@testable import Koda

@MainActor
struct KodaTests {
    @Test
    func profileValidationSavingAndRecovery() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let viewModel = CreateProfileViewModel()

        #expect(!viewModel.canSave)
        #expect(!viewModel.saveProfile(using: context))

        viewModel.name = "  Ana  "
        viewModel.selectedAvatar = .sofia

        #expect(viewModel.canSave)
        #expect(viewModel.saveProfile(using: context))

        let recovered = CreateProfileViewModel()
        recovered.loadProfile(using: context)

        #expect(recovered.name == "Ana")
        #expect(recovered.selectedAvatar == .sofia)
        #expect(try profiles(in: context).count == 1)
    }

    @Test
    func familiarChoicePersistsAndRoutesDirectlyToPOO() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let profile = try savedProfile(in: context)
        let viewModel = KnowledgeCheckViewModel()

        viewModel.selection = .familiar

        #expect(viewModel.save(profile: profile, context: context))
        #expect(profile.needsBasicReview == false)
        #expect(stage(for: profile) == .topics)
    }

    @Test
    func needsReviewChoicePersistsAndRoutesToFundamentals() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let profile = try savedProfile(in: context)
        let viewModel = KnowledgeCheckViewModel()

        viewModel.selection = .needsReview

        #expect(viewModel.save(profile: profile, context: context))
        #expect(profile.needsBasicReview == true)
        #expect(stage(for: profile) == .fundamentals)
    }

    @Test
    func incorrectAnswerCannotAdvance() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let profile = try savedProfile(in: context)
        let viewModel = FundamentalsReviewViewModel()
        let lesson = FundamentalsLesson.lessons[0]
        let incorrectAnswer = (lesson.correctAnswer + 1) % lesson.answers.count

        viewModel.selectedAnswer = incorrectAnswer
        viewModel.checkAnswer(for: lesson)

        #expect(!viewModel.isCorrect(for: lesson))
        #expect(!viewModel.advance(profile: profile, context: context))
        #expect(profile.fundamentalsStep == nil)
    }

    @Test
    func fourCorrectAnswersCompleteReview() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let profile = try savedProfile(in: context)
        profile.needsBasicReview = true
        try context.save()
        let viewModel = FundamentalsReviewViewModel()

        for lesson in FundamentalsLesson.lessons {
            viewModel.selectedAnswer = lesson.correctAnswer
            viewModel.checkAnswer(for: lesson)
            #expect(viewModel.advance(profile: profile, context: context))
        }

        #expect(profile.fundamentalsStep == 4)
        #expect(stage(for: profile) == .topics)
    }

    @Test
    func savingChoiceAndProgressPreservesProfileIdentity() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let profile = try savedProfile(
            name: "María",
            avatar: .valeria,
            in: context
        )
        let knowledge = KnowledgeCheckViewModel()
        knowledge.selection = .needsReview
        #expect(knowledge.save(profile: profile, context: context))

        let review = FundamentalsReviewViewModel()
        let lesson = FundamentalsLesson.lessons[0]
        review.selectedAnswer = lesson.correctAnswer
        review.checkAnswer(for: lesson)
        #expect(review.advance(profile: profile, context: context))

        let persisted = try #require(profiles(in: context).first)
        #expect(persisted.name == "María")
        #expect(persisted.avatarName == ProfileAvatar.valeria.rawValue)
    }

    @Test
    func operationsDoNotCreateDuplicateProfiles() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let create = CreateProfileViewModel()
        create.name = "Leo"
        create.selectedAvatar = .leo

        #expect(create.saveProfile(using: context))
        create.name = "Leonardo"
        #expect(create.saveProfile(using: context))

        let profile = try #require(profiles(in: context).first)
        let knowledge = KnowledgeCheckViewModel()
        knowledge.selection = .needsReview
        #expect(knowledge.save(profile: profile, context: context))

        let review = FundamentalsReviewViewModel()
        let lesson = FundamentalsLesson.lessons[0]
        review.selectedAnswer = lesson.correctAnswer
        review.checkAnswer(for: lesson)
        #expect(review.advance(profile: profile, context: context))

        #expect(try profiles(in: context).count == 1)
    }

    private func makeContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: StudentProfile.self,
            configurations: configuration
        )
    }

    private func savedProfile(
        name: String = "Ana",
        avatar: ProfileAvatar = .alex,
        in context: ModelContext
    ) throws -> StudentProfile {
        let viewModel = CreateProfileViewModel()
        viewModel.name = name
        viewModel.selectedAvatar = avatar
        #expect(viewModel.saveProfile(using: context))
        return try #require(profiles(in: context).first)
    }

    private func profiles(in context: ModelContext) throws -> [StudentProfile] {
        try context.fetch(FetchDescriptor<StudentProfile>())
    }

    private func stage(for profile: StudentProfile) -> OnboardingStage {
        OnboardingStage.resolve(
            hasProfile: true,
            needsReview: profile.needsBasicReview,
            completedSteps: profile.fundamentalsStep ?? 0,
            totalSteps: FundamentalsLesson.lessons.count
        )
    }
}
